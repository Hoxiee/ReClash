import 'dart:convert';

import 'package:material_color_utilities/material_color_utilities.dart';

import 'report.dart';

const _escape = HtmlEscape();

// The app's default seed and status hues; `lib/common` would pull Flutter
// into the packing isolate.
const _seed = 0xFFFF9500;
const _green = 0xFF4CAF50;
const _amber = 0xFFFF9800;

/// `report.html`: one offline page that renders the embedded report data.
/// Runs inside the packing isolate, so it must stay plain Dart.
String renderReportHtml(ReportData data) {
  final json = jsonEncode(
    data.toJson(withConfig: false),
  ).replaceAll('<', r'\u003c');
  final id = _escape.convert(data.id);
  return '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'">
<title>ReClash report $id</title>
<style>
:root{color-scheme:light dark;${_palette(dark: false)}}
@media (prefers-color-scheme:dark){:root{${_palette(dark: true)}}}
$_css</style>
</head>
<body>
<main id="app"></main>
<noscript><p>Report $id. Open 01-summary.md and the JSON files.</p></noscript>
<script id="report" type="application/json">$json</script>
<script>$_js</script>
</body>
</html>
''';
}

String _palette({required bool dark}) {
  final scheme = SchemeContent(
    sourceColorHct: Hct.fromInt(_seed),
    isDark: dark,
    contrastLevel: 0,
  );
  final green = _status(_green);
  final amber = _status(_amber);
  final (accent, container, onContainer) = dark ? (80, 30, 90) : (40, 90, 10);
  final colors = {
    'bg': scheme.surface,
    'card': scheme.surfaceContainer,
    'card2': scheme.surfaceContainerHighest,
    'fg': scheme.onSurface,
    'muted': scheme.onSurfaceVariant,
    'line': scheme.outlineVariant,
    'primary': scheme.primary,
    'pc': scheme.primaryContainer,
    'on-pc': scheme.onPrimaryContainer,
    'sc': scheme.secondaryContainer,
    'on-sc': scheme.onSecondaryContainer,
    'err': scheme.error,
    'on-err': scheme.onError,
    'ec': scheme.errorContainer,
    'on-ec': scheme.onErrorContainer,
    'ok': green.get(accent),
    'okc': green.get(container),
    'on-okc': green.get(onContainer),
    'warn': amber.get(accent),
    'warnc': amber.get(container),
    'on-warnc': amber.get(onContainer),
  };
  return [
    for (final MapEntry(:key, :value) in colors.entries)
      '--$key:#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
  ].join(';');
}

TonalPalette _status(int color) =>
    TonalPalette.of(Hct.fromInt(Blend.harmonize(color, _seed)).hue, 36);

const _css = r'''
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:.875rem/1.45 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:61.25rem;margin:0 auto;padding:1.75rem 1rem 2.5rem;display:grid;grid-template-columns:minmax(0,1fr);gap:.75rem}
.mono,.id,pre{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
header{display:grid;gap:.25rem;padding:0 .25rem .5rem}
.brand{display:flex;align-items:center;gap:.5rem;color:var(--muted);font-size:.8125rem;font-weight:500}
.brand::before{content:"";width:.625rem;height:.625rem;border-radius:50%;background:var(--primary)}
.id{justify-self:start;font-size:1.75rem;font-weight:600;letter-spacing:.02em;color:var(--fg);background:none;border:0;padding:0;cursor:copy}
.id.copied::after{content:" ✓";color:var(--ok)}
.meta{color:var(--muted);font-size:.8125rem}
.card,.sec{background:var(--card);border-radius:1.25rem}
.verdict{padding:1.125rem 1.25rem;display:grid;gap:.375rem}
.verdict.bad{background:var(--ec);color:var(--on-ec)}
.verdict.good{background:var(--okc);color:var(--on-okc)}
.v-title{font-size:1.25rem;font-weight:600}
.v-detail{opacity:.85}
blockquote{margin:.25rem 0 0;padding-left:.75rem;border-left:.1875rem solid currentColor;font-style:italic;opacity:.85}
.sec{padding:0 1rem}
.sec>summary{list-style:none;cursor:pointer;display:flex;align-items:center;gap:.5rem;padding:.875rem 0;user-select:none}
.sec>summary::-webkit-details-marker{display:none}
.sec>summary::after{content:"";margin-left:auto;width:.4375rem;height:.4375rem;border-right:.125rem solid var(--muted);border-bottom:.125rem solid var(--muted);transform:rotate(45deg);transition:transform .15s}
.sec[open]>summary::after{transform:rotate(-135deg)}
.sec[open]{padding-bottom:.875rem}
h2{font-size:1rem;font-weight:600;margin:0}
.count{color:var(--muted);font-size:.8125rem}
.pill,.chip{display:inline-flex;align-items:center;border-radius:62.4375rem;font-size:.75rem;font-weight:500;white-space:nowrap}
.pill{padding:.125rem .625rem;background:var(--card2);color:var(--muted)}
.ok{--c:var(--okc);--on:var(--on-okc)}
.err{--c:var(--ec);--on:var(--on-ec)}
.warn{--c:var(--warnc);--on:var(--on-warnc)}
.tip{--c:var(--card2);--on:var(--muted)}
.pill.ok,.pill.err,.pill.warn,.pill.tip,.step.ok,.step.err,.step.warn{background:var(--c);color:var(--on)}
.verdict .pill{background:color-mix(in srgb,currentColor 12%,transparent);color:inherit}
.chips{display:flex;flex-wrap:wrap;gap:.375rem;margin:.125rem 0 .625rem}
.chip{border:0;font:inherit;font-size:.75rem;padding:.25rem .75rem;background:var(--card2);color:var(--fg);cursor:pointer}
.chip.on{background:var(--sc);color:var(--on-sc)}
.verdict .chips{margin-bottom:0}
.row{display:flex;gap:.75rem;align-items:flex-start;padding:.625rem 0}
.row+.row{border-top:.0625rem solid var(--line)}
.grow{flex:1;min-width:0}
.dot{width:.625rem;height:.625rem;border-radius:50%;margin-top:.3125rem;flex:none;background:var(--muted)}
.dot.err{background:var(--err)}.dot.warn{background:var(--warn)}.dot.ok{background:var(--ok)}
.t{font-weight:600;overflow-wrap:anywhere}
.sub{color:var(--muted);font-size:.8125rem;overflow-wrap:anywhere}
.chain{display:grid;grid-template-columns:repeat(auto-fill,minmax(5.25rem,1fr));gap:.375rem;margin-bottom:.5rem}
.step{display:grid;padding:.5rem .75rem;border-radius:.875rem;background:var(--card2)}
.step.err{background:var(--err);color:var(--on-err)}
.step b{font-size:.8125rem;font-weight:600}
.step span{font-size:.75rem;opacity:.75}
.scroll{overflow-x:auto}
table{width:100%;border-collapse:collapse;font-size:.8125rem}
th{text-align:left;font-weight:600;color:var(--muted);padding:.375rem .5rem;white-space:nowrap}
th.sort{cursor:pointer;user-select:none}
th[data-sort=asc]::after{content:" ↑"}th[data-sort=desc]::after{content:" ↓"}
td{padding:.375rem .5rem;border-top:.0625rem solid var(--line);white-space:nowrap}
.num{text-align:right;font-variant-numeric:tabular-nums}
dl{display:grid;grid-template-columns:max-content 1fr;gap:.25rem 1rem;margin:0 0 .75rem}
dt{color:var(--muted)}dd{margin:0;overflow-wrap:anywhere}
.log>summary{cursor:pointer;padding:.375rem 0;color:var(--muted)}
pre{margin:.25rem 0 .5rem;background:var(--card2);padding:.75rem;border-radius:.875rem;overflow:auto;max-height:30rem;font-size:.75rem;line-height:1.5}
.l-err{color:var(--err)}.l-warn{color:var(--warn)}
footer{color:var(--muted);font-size:.75rem;text-align:center;padding-top:.25rem}
@supports (corner-shape:squircle){.card,.sec,.step,pre,.pill,.chip{corner-shape:squircle}.card,.sec{border-radius:2rem}.step,pre{border-radius:1.375rem}}
@media (max-width:37.5rem){main{padding:1.25rem .75rem 2rem}.id{font-size:1.375rem}}
''';

const _js = r'''
"use strict";
const D=JSON.parse(document.getElementById("report").textContent);
const M=D.manifest||{},S=D.summary||{};
const $=(tag,attrs,...kids)=>{
  const e=document.createElement(tag);
  for(const[k,v]of Object.entries(attrs||{})){
    if(v==null||v===false)continue;
    if(k==="on")for(const[ev,f]of Object.entries(v))e.addEventListener(ev,f);
    else e.setAttribute(k,v===true?"":v);
  }
  for(const c of kids.flat(Infinity))if(c!=null&&c!==false)e.append(c instanceof Node?c:String(c));
  return e;
};
const tones={pass:"ok",ok:"ok",available:"ok",critical:"err",fail:"err",warning:"warn",tip:"tip",skipped:"",unknown:"",waiting:"",running:""};
const tone=s=>s in tones?tones[s]:"err";
const pill=(text,t)=>$("span",{class:"pill "+(t||"")},text);
const when=s=>s?new Date(s).toLocaleString(undefined,{dateStyle:"medium",timeStyle:"short"}):"";
const ms=v=>v==null?"—":v+" ms";
const dur=v=>v==null?null:v<1000?v+" ms":(v/1000).toFixed(1)+" s";
const cap=s=>s?s[0].toUpperCase()+s.slice(1):s;
const bytes=n=>{if(n==null)return null;const u=["B","KB","MB","GB","TB"];let i=0;while(n>=1024&&i<4){n/=1024;i++}return(i?n.toFixed(1):n)+" "+u[i]};
const join=(...p)=>p.filter(x=>x!=null&&x!=="").join(" · ");
const value=v=>v==null?"—":typeof v==="object"?JSON.stringify(v):String(v);
const kv=pairs=>$("dl",{},pairs.filter(p=>p[1]!=null&&p[1]!=="").map(([k,v])=>[$("dt",{},k),$("dd",{},v)]));
const sec=(title,count,open,...body)=>$("details",{class:"sec",open},$("summary",{},$("h2",{},title),count!=null?$("span",{class:"count"},count):null),...body);
const app=document.getElementById("app");

app.append($("header",{},
  $("div",{class:"brand"},"ReClash report"),
  $("button",{class:"id",title:"Copy",on:{click:e=>{navigator.clipboard&&navigator.clipboard.writeText(M.id);e.currentTarget.classList.add("copied")}}},M.id),
  $("div",{class:"meta"},join(when(M.createdAt),S.app,S.os,S.device,S.profile,M.redaction==="public"?"public redaction":null))));

{
  const fail=S.verdict==="fail",pass=S.verdict==="pass";
  const counts=S.servers?Object.entries(S.servers).filter(([k])=>!["total","ok","skipped","unknown"].includes(k)):[];
  app.append($("section",{class:"card verdict "+(fail?"bad":pass?"good":"")},
    $("div",{class:"v-title"},fail?"Fails at "+(S.failedStep||"an unknown step"):pass?"Connection works":"Not checked"),
    fail&&(S.cause||S.detail)?$("div",{class:"v-detail"},join(S.cause,S.detail)):null,
    (S.healed||[]).length?$("div",{class:"v-detail"},"Auto-repair: "+S.healed.map(h=>h.remedy+" → "+h.outcome).join(", ")):null,
    S.note?$("blockquote",{},S.note):null,
    S.servers?$("div",{class:"chips"},pill((S.servers.ok||0)+" of "+S.servers.total+" servers ok"),counts.map(([k,n])=>pill(k+" "+n))):null));
}

if(D.findings&&D.findings.length)app.append(sec("Findings",D.findings.length,true,
  D.findings.map(f=>$("div",{class:"row"},
    $("span",{class:"dot "+tone(f.severity)}),
    $("div",{class:"grow"},
      $("div",{class:"t"},f.id),
      $("div",{class:"sub"},join(f.cause&&"cause: "+f.cause,Object.entries(f.args||{}).map(([k,v])=>k+": "+v).join(", "))),
      (f.tried||[]).length?$("div",{class:"sub"},"Tried: "+f.tried.map(t=>t.remedy+(t.action==="undo"?" (undo)":"")+" → "+t.outcome+(t.detail?" ("+t.detail+")":"")).join(", ")):null),
    pill(f.severity,tone(f.severity))))));

if(D.path){
  const P=D.path;
  app.append(sec("Path",join(cap(P.verdict),dur(P.durationMs),P.cancelled?"cancelled":null,P.fresh===false?"cached":null),true,
    $("div",{class:"chain"},P.steps.map(s=>$("div",{class:"step "+tone(s.status),title:join(s.cause,s.detail)},$("b",{},s.step),$("span",{},s.status==="pass"?ms(s.durationMs):s.status)))),
    P.steps.filter(s=>(s.detail||s.cause)&&!(s.step===S.failedStep&&s.detail===S.detail)).map(s=>$("div",{class:"sub"},s.step+": "+join(s.cause,s.detail)))));
}

if(D.servers&&D.servers.length){
  const cols=[["node","Node"],["status","Status"],["delayMs","Delay, ms"],["tcpMs","TCP, ms"],["resolveMs","DNS, ms"],["lastDelayMs","Last test, ms"],["group","Group"],["type","Type"],["server","Server"]];
  const rank=r=>r.status==="ok"?2:r.status==="skipped"||r.status==="unknown"?1:0;
  let key="status",dir=1,only=null;
  const body=$("tbody"),chips=$("div",{class:"chips"});
  const head=$("tr",{},cols.map(([k,l])=>$("th",{class:"sort"+(k.endsWith("Ms")?" num":""),on:{click:()=>{dir=key===k?-dir:1;key=k;draw()}}},l)));
  const cell=(r,k)=>k==="status"?pill(r.status,tone(r.status)):k==="server"?r.server+":"+r.port:k.endsWith("Ms")?(r[k]==null?"—":r[k]):r[k];
  const draw=()=>{
    const rows=D.servers.filter(r=>!only||r.status===only).sort((a,b)=>{
      const x=key==="status"?rank(a):a[key],y=key==="status"?rank(b):b[key];
      if(x==null)return y==null?0:1;if(y==null)return-1;
      return(x<y?-1:x>y?1:0)*dir;
    });
    body.replaceChildren(...rows.map(r=>$("tr",{},cols.map(([k])=>$("td",{class:k.endsWith("Ms")?"num":k==="server"?"mono":null},cell(r,k))))));
    [...head.children].forEach((th,i)=>th.dataset.sort=cols[i][0]===key?(dir>0?"asc":"desc"):"");
    [...chips.children].forEach(c=>c.classList.toggle("on",c.dataset.status===(only||"")));
  };
  const counts={};for(const r of D.servers)counts[r.status]=(counts[r.status]||0)+1;
  chips.append($("button",{class:"chip","data-status":"",on:{click:()=>{only=null;draw()}}},"All "+D.servers.length),
    ...Object.entries(counts).map(([s,n])=>$("button",{class:"chip","data-status":s,on:{click:()=>{only=s;draw()}}},s+" "+n)));
  app.append(sec("Servers",D.servers.length,true,chips,$("div",{class:"scroll"},$("table",{},$("thead",{},head),body))));
  draw();
}

if(D.services){
  const V=D.services,check=c=>c?pill(join(c.status,c.delayMs!=null?c.delayMs+" ms":null,c.region),tone(c.status)):"—";
  app.append(sec("Services",(V.checks||[]).length,false,
    $("div",{class:"scroll"},$("table",{},$("thead",{},$("tr",{},$("th",{},"Service"),$("th",{},"Through tunnel"),$("th",{},"Direct"))),
      $("tbody",{},(V.checks||[]).map(c=>$("tr",{},$("td",{},c.label||c.service),$("td",{},check(c.routed)),$("td",{},check(c.direct))))))),
    V.routedError?$("div",{class:"sub"},"Tunnel: "+V.routedError):null,
    V.directError?$("div",{class:"sub"},"Direct: "+V.directError):null));
}

if(D.profile){
  const P=D.profile,U=P.usage||{};
  app.append(sec("Profile",P.label,false,
    kv([["Source",P.source],["Updated",when(P.updatedAt)],["Auto-update",P.autoUpdate?(P.autoUpdateMinutes?P.autoUpdateMinutes+" min":"on"):"off"],
      ["Traffic",U.total?bytes((U.upload||0)+(U.download||0))+" / "+bytes(U.total):null],["Expires",U.expire?when(U.expire*1000):null],
      ...Object.entries(P.subscription||{}).map(([k,v])=>[k,value(v)])]),
    (P.groups||[]).length?$("div",{class:"scroll"},$("table",{},$("thead",{},$("tr",{},["Group","Type","Selected","Nodes"].map(h=>$("th",{},h)))),
      $("tbody",{},P.groups.map(g=>$("tr",{},$("td",{},g.name+(g.name===P.currentGroup?" •":"")),$("td",{},g.type),$("td",{},g.now||"—"),$("td",{class:"num"},g.nodes)))))):null,
    (P.updates||[]).length?$("div",{class:"sub"},"Updates: "+P.updates.map(u=>when(u.at)+" "+(u.ok?"ok":"failed"+(u.error?" ("+u.error+")":""))).join(", ")):null));
}

if(D.environment){
  const E=D.environment,facts=Object.entries(E.facts||{});
  app.append(sec("Environment",facts.length,false,
    kv(facts.map(([k,f])=>[k,f.stale?[value(f.value)," ",pill("stale")]:value(f.value)])),
    kv([["Interfaces",(E.interfaces||[]).map(i=>i.name+" "+(i.addresses||[]).join(", ")).join(" · ")],["IPv6",E.ipv6==null?null:E.ipv6?"yes":"no"]])));
}

if(D.history){
  const events=[];
  for(const[k,list]of Object.entries(D.history))if(Array.isArray(list))for(const{at,kind,...rest}of list)events.push({at,kind:kind||k,rest});
  events.sort((a,b)=>a.at<b.at?1:-1);
  app.append(sec("History",events.length,false,
    events.map(e=>$("div",{class:"row"},$("span",{class:"sub mono"},when(e.at)),$("div",{class:"grow"},$("span",{class:"t"},e.kind)," ",
      $("span",{class:"sub"},Object.entries(e.rest).map(([k,v])=>k+": "+value(v)).join(", ")))))));
}

if(D.logs){
  const names={core:"logs/core.log",app:"logs/app.log",logcat:"logs/logcat.txt",capture:"logs/capture.log"};
  const L=Object.entries(D.logs).filter(([,l])=>l&&l.length);
  if(L.length)app.append(sec("Logs",L.reduce((n,[,l])=>n+l.length,0)+" lines",false,
    L.map(([k,lines])=>{
      const pre=$("pre");
      return $("details",{class:"log",on:{toggle:e=>{if(e.currentTarget.open&&!pre.firstChild)pre.append(...lines.map(l=>$("div",{class:/\b(ERROR|FATAL|error)\b/.test(l)?"l-err":/\bWARN(ING)?\b/.test(l)?"l-warn":null},l)))}}},
        $("summary",{},(names[k]||k)+" · "+lines.length+" lines"),pre);
    })));
}

app.append($("footer",{},join(M.app?M.app.name+" "+M.app.version:null,"Config in 09-config.yaml",D.schema)));
''';
