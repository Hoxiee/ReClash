package com.reclash.packages

import java.io.InputStream

/**
 * Prefixes match *without* a trailing dot boundary on purpose: `com.qihoo` has
 * to reach `com.qihoo360.*` and `com.ali` has to reach `com.aliyun.*`. Namespace
 * zones (`ru.`, `su.`, `ir.`) carry the dot in the entry itself, so the same
 * plain-prefix test treats them as a whole segment and never drags in `ruby.*`.
 */
internal class DomesticPackageMatcher(
    private val openAsset: (String) -> InputStream,
) {

    private val listLock = Any()
    private val explicitLists = HashMap<String, Set<String>>()

    fun isSkipped(packageName: String): Boolean = SKIPPED_PREFIXES.any {
        packageName == it || packageName.startsWith("$it.")
    }

    fun matchesExplicit(packageName: String, region: String): Boolean =
        explicitList(region).contains(packageName)

    fun matchesNamePrefix(packageName: String, region: String): Boolean =
        namePrefixes(region).any(packageName::startsWith)

    fun matchesClass(className: String, region: String): Boolean =
        classPrefixes(region).any(className::startsWith)

    fun hasClassSignatures(region: String): Boolean = classPrefixes(region).isNotEmpty()

    fun classNameOf(descriptor: String): String = descriptor
        .removeSurrounding("L", ";")
        .replace('/', '.')
        .replace('$', '.')

    private fun explicitList(region: String): Set<String> {
        val assetPath = EXPLICIT_LIST_ASSETS[region] ?: return emptySet()
        explicitLists[region]?.let { return it }
        return synchronized(listLock) {
            explicitLists[region] ?: loadList(assetPath).also { explicitLists[region] = it }
        }
    }

    private fun loadList(assetPath: String): Set<String> = runCatching {
        openAsset(assetPath).bufferedReader().useLines { lines ->
            lines.map { it.substringBefore('#').trim().lowercase() }
                .filter(String::isNotEmpty)
                .toHashSet()
        }
    }.getOrDefault(emptySet())

    private fun namePrefixes(region: String): Set<String> = when (region) {
        "cn" -> CN_PREFIXES
        "ru" -> RU_NAME_PREFIXES
        "ir" -> IR_NAME_PREFIXES
        else -> emptySet()
    }

    private fun classPrefixes(region: String): Set<String> = when (region) {
        "cn" -> CN_PREFIXES
        "ru" -> RU_SDK_PREFIXES
        "ir" -> IR_SDK_PREFIXES
        else -> emptySet()
    }

    companion object {
        private val EXPLICIT_LIST_ASSETS = mapOf(
            "ru" to "domestic/ru/apps.txt",
            "ir" to "domestic/ir/apps.txt",
        )

        // com.mxtech / com.stubhub only exist to neutralize the loose CN prefixes
        // com.mx (Maxthon) and com.stub (StubApp packer); harmless for other regions.
        private val SKIPPED_PREFIXES = listOf(
            "org.telegram",
            "com.google",
            "com.android.chrome",
            "com.android.vending",
            "com.microsoft",
            "com.apple",
            "com.facebook.katana",
            "com.instagram.android",
            "com.whatsapp",
            "com.zhiliaoapp.musically",
            "com.spotify.music",
            "com.netflix.mediaclient",
            "com.mxtech",
            "com.stubhub",
        )

        private val CN_PREFIXES = setOf(
            "com.tencent",
            "com.alibaba",
            "com.umeng",
            "com.qihoo",
            "com.ali",
            "com.alipay",
            "com.amap",
            "com.sina",
            "com.weibo",
            "com.vivo",
            "com.xiaomi",
            "com.huawei",
            "com.taobao",
            "com.secneo",
            "s.h.e.l.l",
            "com.stub",
            "com.kiwisec",
            "com.secshell",
            "com.wrapper",
            "cn.securitystack",
            "com.mogosec",
            "com.secoen",
            "com.netease",
            "com.mx",
            "com.qq.e",
            "com.baidu",
            "com.bytedance",
            "com.bugly",
            "com.miui",
            "com.oppo",
            "com.coloros",
            "com.iqoo",
            "com.meizu",
            "com.gionee",
            "cn.nubia",
            "com.oplus",
            "andes.oplus",
            "com.unionpay",
            "cn.wps",
        )

        private val RU_NAME_PREFIXES = setOf(
            "ru.",
            "su.",
            "com.yandex",
            "com.vk",
            "com.vkontakte",
            "com.megafon",
            "com.wildberries",
            "com.sberbank",
            "com.sbermarket",
            "com.sberauto",
            "com.salute",
            "com.sdkit",
            "com.zvooq",
            "com.rutube",
            "com.rostelecom",
            "com.ozon",
            "com.magnit",
            "com.mts",
            "com.vkusvill",
            "com.lenta",
            "com.gnivts",
            "com.dartit",
            "com.indygomobi",
        )

        private val RU_SDK_PREFIXES = setOf(
            "io.appmetrica.analytics",
            "com.yandex.metrica",
            "com.yandex.mobile.ads",
            "com.yandex.mapkit",
            "com.yandex.runtime",
            "com.yandex.authsdk",
            "com.vk.id",
            "com.vk.api.sdk",
            "com.vk.sdk",
            "com.vk.superapp",
            "com.my.target",
            "com.my.tracker",
            "ru.mail.mrgservice",
            "ru.rustore.sdk",
            "ru.sberdevices.services",
            "ru.sberbank.sdakit",
            "ru.tinkoff.acquiring",
            "ru.tinkoff.core",
            "ru.yoomoney.sdk",
            "cloud.mindbox",
            "com.flocktory",
            "ru.tachos.admitadstatisticsdk",
            "ru.wapstart.plus1.sdk",
        )

        private val IR_NAME_PREFIXES = setOf(
            "ir.",
            "cab.snapp",
            "express.snapp",
            "taxi.tap30",
            "mob.banking.android",
            "com.tosan",
            "com.sabaidea",
            "com.aparat",
            "com.samanpr",
            "com.shatelland",
            "com.adpdigital",
        )

        private val IR_SDK_PREFIXES = setOf(
            "ir.tapsell",
            "ir.metrix",
            "com.adivery.sdk",
            "co.pushe.plus",
            "io.adtrace",
            "ir.cafebazaar.poolakey",
            "ir.myket.billingclient",
            "com.adpdigital",
        )
    }
}
