package com.reclash.packages

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DomesticPackageMatcherTest {

    // Reads the same asset files the APK ships, from the module source tree.
    private val matcher = DomesticPackageMatcher { path ->
        File("src/main/assets").resolve(path).inputStream()
    }

    @Test
    fun `telegram is skipped for every region`() {
        assertTrue(matcher.isSkipped("org.telegram.messenger"))
        for (region in listOf("ru", "ir", "cn", "other")) {
            assertFalse(region, matcher.matchesExplicit("org.telegram.messenger", region))
            assertFalse(region, matcher.matchesNamePrefix("org.telegram.messenger", region))
        }
    }

    @Test
    fun `the skip list applies a dot boundary`() {
        assertTrue(matcher.isSkipped("com.google"))
        assertTrue(matcher.isSkipped("com.google.android.gms"))
        assertFalse(matcher.isSkipped("com.googlefoo"))
    }

    @Test
    fun `ru and su namespace zones match for ru as whole segments`() {
        assertTrue(matcher.matchesNamePrefix("ru.sberbankmobile", "ru"))
        assertTrue(matcher.matchesNamePrefix("su.example.app", "ru"))
        assertFalse(matcher.matchesNamePrefix("ruby.orm", "ru"))
    }

    @Test
    fun `confirmed ru vendors match by name prefix`() {
        assertTrue(matcher.matchesNamePrefix("com.vkontakte.android", "ru"))
        assertTrue(matcher.matchesNamePrefix("com.sberbank.online", "ru"))
        assertTrue(matcher.matchesNamePrefix("ru.yandex.searchplugin", "ru"))
    }

    @Test
    fun `a vanity tail id matches ru only through the explicit list`() {
        assertTrue(matcher.matchesExplicit("com.avito.android", "ru"))
        assertFalse(matcher.matchesNamePrefix("com.avito.android", "ru"))
    }

    @Test
    fun `an ru sdk class name normalizes and matches layer c`() {
        val className = matcher.classNameOf("Lio/appmetrica/analytics/Foo\$Bar;")
        assertEquals("io.appmetrica.analytics.Foo.Bar", className)
        assertTrue(matcher.matchesClass(className, "ru"))
    }

    @Test
    fun `ir apps match across the three layers`() {
        assertTrue(matcher.matchesNamePrefix("cab.snapp.passenger", "ir"))
        assertTrue(matcher.matchesNamePrefix("ir.divar", "ir"))
        assertTrue(matcher.matchesExplicit("com.farsitel.bazaar", "ir"))
        assertTrue(matcher.matchesClass(matcher.classNameOf("Lir/tapsell/Plus;"), "ir"))
    }

    @Test
    fun `cn vendors and packer class names still match for cn`() {
        assertTrue(matcher.matchesNamePrefix("com.tencent.mm", "cn"))
        assertTrue(matcher.matchesNamePrefix("com.qihoo360.mobilesafe", "cn"))
        assertTrue(matcher.matchesClass("com.stub.StubApp", "cn"))
        assertTrue(matcher.matchesClass("s.h.e.l.l.S", "cn"))
        assertTrue(matcher.isSkipped("com.zhiliaoapp.musically"))
    }

    @Test
    fun `a junk prefix never matches by prefix`() {
        assertFalse(matcher.matchesNamePrefix("com.example.anything", "ir"))
        assertFalse(matcher.matchesExplicit("com.example.anything", "ir"))
    }

    @Test
    fun `region other and unknown regions match nothing`() {
        for (region in listOf("other", "us", "")) {
            assertFalse(region, matcher.matchesExplicit("com.avito.android", region))
            assertFalse(region, matcher.matchesNamePrefix("ru.sberbankmobile", region))
            assertFalse(region, matcher.matchesClass("io.appmetrica.analytics.Foo", region))
            assertFalse(region, matcher.hasClassSignatures(region))
        }
    }
}
