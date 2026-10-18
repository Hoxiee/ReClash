package com.reclash.packages

import java.io.File
import java.util.Locale
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DomesticPackageMatcherTest {

    private val matcher = DomesticPackageMatcher { path ->
        File("src/main/assets").resolve(path).inputStream()
    }

    @Test
    fun `manifest includes all supported domestic regions`() {
        assertEquals(setOf("ru", "ir", "cn", "eg"), matcher.domesticRegions)
    }

    @Test
    fun `regional datasets match their explicit packages and prefixes`() {
        val samples = mapOf(
            "ru" to ("com.avito.android" to "ru.yandex.searchplugin"),
            "ir" to ("com.farsitel.bazaar" to "cab.snapp.passenger"),
            "eg" to ("com.cibeg.app" to "eg.sample.app"),
        )
        samples.forEach { (region, sample) ->
            assertTrue("$region explicit", matcher.matchesExplicit(sample.first, region))
            assertTrue("$region prefix", matcher.matchesNamePrefix(sample.second, region))
        }
        assertFalse(matcher.matchesExplicit("com.tencent.mm", "cn"))
        assertTrue(matcher.matchesNamePrefix("com.tencent.mm", "cn"))
    }

    @Test
    fun `shared skips include telegram and take dot boundaries`() {
        assertTrue(matcher.isSkipped("org.telegram.messenger"))
        assertTrue(matcher.isSkipped("com.google.android.gms"))
        assertFalse(matcher.isSkipped("com.googlefoo"))
        for (region in matcher.domesticRegions) {
            assertFalse(region, matcher.matchesExplicit("org.telegram.messenger", region))
            assertFalse(region, matcher.matchesNamePrefix("org.telegram.messenger", region))
        }
    }

    @Test
    fun `sdk classes normalize and match the relevant regions`() {
        val ruClass = matcher.classNameOf("Lio/appmetrica/analytics/Foo\$Bar;")
        assertEquals("io.appmetrica.analytics.Foo.Bar", ruClass)
        assertTrue(matcher.matchesClass(ruClass, "ru"))
        assertTrue(matcher.matchesClass("ir.tapsell.Plus", "ir"))
        assertTrue(matcher.matchesClass("com.stub.StubApp", "cn"))
        assertTrue(matcher.matchesClass("s.h.e.l.l.S", "cn"))
    }

    @Test
    fun `dataset and class matching do not depend on the device locale`() {
        val previous = Locale.getDefault()
        try {
            Locale.setDefault(Locale.forLanguageTag("tr-TR"))
            val localMatcher = DomesticPackageMatcher { path ->
                File("src/main/assets").resolve(path).inputStream()
            }
            assertTrue(localMatcher.matchesExplicit("com.avito.android", "ru"))
            assertTrue(localMatcher.matchesClass("IO.APPMETRICA.analytics.Foo", "ru"))
            assertTrue(localMatcher.matchesClass("IR.TAPSELL.Plus", "ir"))
        } finally {
            Locale.setDefault(previous)
        }
    }

    @Test
    fun `cn vendors retain prefix and skip behavior`() {
        assertTrue(matcher.matchesNamePrefix("com.tencent.mm", "cn"))
        assertTrue(matcher.matchesNamePrefix("com.qihoo360.mobilesafe", "cn"))
        assertTrue(matcher.isSkipped("com.zhiliaoapp.musically"))
        assertFalse(matcher.isSkipped("com.mx.browser"))
        assertFalse(matcher.matchesNamePrefix("com.google.android.gms", "cn"))
    }

    @Test
    fun `cn keeps legacy loose prefix and exclusion behavior`() {
        val loosePrefixMisses = listOf(
            "com.mxtech.videoplayer.ad",
            "com.stubhub",
        )
        for (name in loosePrefixMisses) {
            assertTrue(name, matcher.matchesNamePrefix(name, "cn"))
            assertTrue(name, matcher.isSkipped(name))
        }
        assertTrue(matcher.matchesNamePrefix("com.mx.browser", "cn"))
        assertFalse(matcher.isSkipped("com.mx.browser"))
        assertTrue(matcher.matchesNamePrefix("com.stub.StubApp", "cn"))
        assertFalse(matcher.isSkipped("com.stub.StubApp"))
        assertTrue(matcher.matchesNamePrefix("com.qihoo360.mobilesafe", "cn"))
        assertTrue(matcher.matchesNamePrefix("com.aliyun.linkcard", "cn"))
        assertTrue(matcher.matchesNamePrefix("com.alimama.moon", "cn"))
    }

    @Test
    fun `unknown regions have no matching layers or sdk scan`() {
        for (region in listOf("other", "us", "")) {
            assertFalse(matcher.matchesExplicit("com.avito.android", region))
            assertFalse(matcher.matchesNamePrefix("ru.sberbankmobile", region))
            assertFalse(matcher.matchesClass("io.appmetrica.analytics.Foo", region))
            assertFalse(matcher.hasClassSignatures(region))
        }
    }
}
