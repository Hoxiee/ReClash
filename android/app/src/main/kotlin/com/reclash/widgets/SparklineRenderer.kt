package com.reclash.widgets

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path

// A bitmap crosses the RemoteViews binder transaction, so the canvas stays
// small and is scaled up by the ImageView instead.
private const val canvasWidth = 480
private const val canvasHeight = 148
private const val canvasInset = 6f

internal object SparklineRenderer {
    fun render(
        down: List<Long>,
        up: List<Long>,
        downColor: Int,
        upColor: Int,
        gridColor: Int,
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(canvasWidth, canvasHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val width = canvasWidth - canvasInset * 2f
        val height = canvasHeight - canvasInset * 2f
        canvas.translate(canvasInset, canvasInset)

        val grid = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = gridColor
            strokeWidth = 1.5f
            style = Paint.Style.STROKE
        }
        for (step in 0..2) {
            val y = height * step / 2f
            canvas.drawLine(0f, y, width, y, grid)
        }

        val peak = sparklinePeak(down, up)
        drawSeries(canvas, sparklinePoints(down, width, height, peak), height, downColor, true)
        drawSeries(canvas, sparklinePoints(up, width, height, peak), height, upColor, false)
        return bitmap
    }

    private fun drawSeries(
        canvas: Canvas,
        points: FloatArray,
        height: Float,
        color: Int,
        filled: Boolean,
    ) {
        if (points.size < 4) return
        val line = Path().apply {
            moveTo(points[0], points[1])
            for (index in 2 until points.size step 2) {
                lineTo(points[index], points[index + 1])
            }
        }
        if (filled) {
            val area = Path(line).apply {
                lineTo(points[points.size - 2], height)
                lineTo(points[0], height)
                close()
            }
            canvas.drawPath(
                area,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    this.color = color
                    alpha = 64
                    style = Paint.Style.FILL
                },
            )
        }
        canvas.drawPath(
            line,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                strokeWidth = 5f
                style = Paint.Style.STROKE
                strokeJoin = Paint.Join.ROUND
                strokeCap = Paint.Cap.ROUND
            },
        )
    }
}
