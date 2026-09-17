package com.reclash.widgets

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOf

@OptIn(ExperimentalCoroutinesApi::class)
internal fun widgetUpdates(
    updates: Flow<Unit>,
    running: Flow<Boolean>,
    interactive: Flow<Boolean>,
    installed: Flow<Boolean>,
    tickMillis: Long,
): Flow<Unit> = combine(interactive, installed) { awake, present -> awake && present }
    .distinctUntilChanged()
    .flatMapLatest { visible ->
        if (!visible) {
            emptyFlow()
        } else {
            val ticker = running.distinctUntilChanged().flatMapLatest { live ->
                if (live) {
                    flow {
                        while (true) {
                            emit(Unit)
                            delay(tickMillis)
                        }
                    }
                } else {
                    flowOf(Unit)
                }
            }
            combine(updates, ticker) { _, _ -> Unit }
        }
    }
