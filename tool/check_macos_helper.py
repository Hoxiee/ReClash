#!/usr/bin/env python3
import ast
import re
import sys
from pathlib import Path


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def read(root, name):
    return (root / name).read_text()


def run(root):
    project = read(root, 'macos/Runner.xcodeproj/project.pbxproj')
    identifiers = re.findall(r'^\t\t([A-F0-9]{24})(?: /\*.*?\*/)? = \{', project, re.M)
    require(len(identifiers) == len(set(identifiers)), 'Duplicate Xcode object identifiers')
    for source in ['HelperMain.swift', 'HelperCoreOwner.swift', 'CoreSpawn.c',
                   'HelperXPC.m', 'HelperPolicy.swift', 'PrivilegedHelperBridge.swift']:
        require(source in project, f'{source} is not in the native target')
    runner = project.split('33CC10EC2044A3C60003C045 /* Runner */ = {', 1)[1].split('\n\t\t};', 1)[0]
    require(runner.index('Copy Core') < runner.index('Embed Signed Helper'),
            'Final signing/hash phase must run after CodeSignOnCopy')
    require('F9A00000000000000000000E' in runner, 'Helper is not a Runner dependency')
    require('com.apple.product-type.tool' in project, 'Missing executable Helper target')
    require(all(value == '12.0' for value in re.findall(r'MACOSX_DEPLOYMENT_TARGET = ([^;]+);', project)),
            'macOS 12 support was changed')
    require('__info_plist' in project and '__launchd_plist' in project, 'SMJobBless sections are missing')

    xpc = read(root, 'macos/Shared/HelperXPC.m')
    require('SecCodeCreateWithXPCMessage' in xpc, 'XPC messages must use their kernel audit token')
    require('kSecGuestAttributeAudit' in xpc and 'LOCAL_PEERTOKEN' in xpc,
            'Exec trampoline must authenticate its parent audit token')
    require('SecCodeCopyGuestWithAttributes' in xpc and 'kSecGuestAttributePid:' not in xpc,
            'Do not authenticate an XPC caller using a supplied PID')
    require('length > 4096' in xpc, 'XPC request size must be bounded')

    policy = read(root, 'macos/Shared/HelperPolicy.swift')
    for token in ['kSecCodeInfoTeamIdentifier', 'anchor apple generic', 'bundleInvalid',
                  'O_NOFOLLOW', 'helperProtocolVersion', 'S_IFLNK', 'info.st_uid == uid']:
        require(token in policy, f'Missing signing/path guard: {token}')
    bridge = read(root, 'macos/Runner/PrivilegedHelperBridge.swift')
    for token in ['reclash/privileged_helper', '#available(macOS 13.0', 'SMAppService.daemon',
                  'SMJobBless', 'SMJobRemove', 'kSMRightModifySystemDaemons',
                  'case .requiresApproval', 'prepareUnregister']:
        require(token in bridge, f'Missing native registration contract: {token}')
    require('LaunchAtLogin' not in bridge, 'GUI autostart must stay separate from privileged registration')
    owner = read(root, 'macos/PrivilegedHelper/HelperCoreOwner.swift')
    for token in ['child.connectionId == peer.connectionID', 'coreStopFailed',
                  'child.sessionId == session', 'connectionInvalidated', 'rc_stop_child',
                  'O_EXCL', 'fsync(output)', 'renameat', 'helperOutdated']:
        require(token in owner, f'Missing scoped process ownership: {token}')

    spawn = read(root, 'macos/PrivilegedHelper/CoreSpawn.c')
    profile_literals = re.findall(r'^\s*(".*"),?$', spawn, re.M)
    profile = ''.join(ast.literal_eval(value) for value in profile_literals)
    require('(deny file-read-data' in profile, 'Privileged Core reads are unconstrained')
    require('(deny file-write*' in profile, 'Privileged Core writes are unconstrained')
    require('(deny process-fork)' in profile and '(deny process-exec' in profile,
            'Privileged Core must not launch arbitrary subprocesses')
    allowed_subpaths = set(re.findall(r'\(subpath "([^"]+)"\)', profile))
    require(allowed_subpaths == {'%s', '/System', '/usr/lib', '/usr/share'},
            f'Unexpected root-readable subtree: {allowed_subpaths}')
    allowed_files = set(re.findall(r'\(literal "([^"]+)"\)', profile))
    require(allowed_files == {'%s', '/etc/hosts', '/private/etc/hosts', '/etc/resolv.conf',
                             '/private/etc/resolv.conf', '/etc/localtime', '/private/etc/localtime',
                             '/dev/null', '/dev/random', '/dev/urandom'},
            f'Unexpected privileged read exception: {allowed_files}')
    require('setreuid(uid, 0)' in spawn and 'setregid(gid, gid)' in spawn,
            'Core must inherit GUI real UID/GID for file ownership reclamation')
    require('POSIX_SPAWN_CLOEXEC_DEFAULT' in spawn, 'Child must not inherit daemon descriptors')

    embed = read(root, 'macos/packaging/helper/embed_helper.sh')
    require(embed.index('codesign --force') < embed.index('core_hash='), 'Hash must cover final signed Core bytes')
    require('<key>BundleProgram</key><string>Contents/Library/LaunchServices/' in embed,
            'SMAppService daemon must use its bundled executable')
    require('helperProtocolVersion' in embed and 'helperSha256' in embed, 'Final manifest omits Helper identity')
    for name in ['macos/Shared/HelperPolicy.swift',
                 'macos/packaging/helper/embed_helper.sh',
                 'macos/packaging/helper/verify_bundle.sh']:
        text = read(root, name)
        require('Contents/Resources/manifest.json' in text,
                f'{name} must keep the integrity manifest in the signed resources')
        require('Contents/MacOS/manifest.json' not in text and '$macos/manifest.json' not in text,
                f'{name} puts unsigned data in a code-only directory')
    metadata = read(root, 'macos/packaging/helper/prepare_metadata.sh')
    require('SMAuthorizedClients' in metadata and 'ProgramArguments' in metadata,
            'Legacy SMJobBless metadata is incomplete')
    for name in ['prepare_metadata.sh', 'embed_helper.sh']:
        text = read(root, f'macos/packaging/helper/{name}')
        for plist in re.findall(r'<<PLIST\n(.*?)\nPLIST', text, re.S):
            import xml.etree.ElementTree as ET
            ET.fromstring(plist)
    native = '\n'.join(read(root, str(path.relative_to(root))) for path in
                       (root / 'macos').rglob('*') if path.suffix in {'.swift', '.m', '.c', '.sh'})
    for forbidden in ['osascript', 'chmod 475', 'StadiumBorder']:
        require(forbidden not in native, f'Forbidden privileged fallback: {forbidden}')
    print('macOS Helper source, Xcode target, registration and sandbox contracts passed')


if __name__ == '__main__':
    root = Path(sys.argv[1]) if len(sys.argv) == 2 else Path(__file__).resolve().parents[1]
    run(root)
