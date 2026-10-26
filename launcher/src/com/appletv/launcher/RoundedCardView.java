package com.appletv.launcher;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Outline;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewOutlineProvider;
import android.widget.FrameLayout;

/**
 * Custom FrameLayout that enforces smooth rounded corners on its background and all children
 * to match Apple TV 4K design specifications and the selection highlight pill (18dp).
 */
public class RoundedCardView extends FrameLayout {
    private final Path clipPath = new Path();
    private final RectF rectF = new RectF();
    private float cornerRadius = 0f;

    public RoundedCardView(Context context) {
        super(context);
        init(context);
    }

    public RoundedCardView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public RoundedCardView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        // 18dp corner radius to exactly match glass_highlight_bg.xml
        cornerRadius = 18f * context.getResources().getDisplayMetrics().density;

        setOutlineProvider(new ViewOutlineProvider() {
            @Override
            public void getOutline(View view, Outline outline) {
                outline.setRoundRect(0, 0, view.getWidth(), view.getHeight(), cornerRadius);
            }
        });
        setClipToOutline(true);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (w > 0 && h > 0) {
            rectF.set(0, 0, w, h);
            clipPath.reset();
            clipPath.addRoundRect(rectF, cornerRadius, cornerRadius, Path.Direction.CW);
        }
    }

    @Override
    public void draw(Canvas canvas) {
        if (!clipPath.isEmpty()) {
            int count = canvas.save();
            canvas.clipPath(clipPath);
            super.draw(canvas);
            canvas.restoreToCount(count);
        } else {
            super.draw(canvas);
        }
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        if (!clipPath.isEmpty()) {
            int count = canvas.save();
            canvas.clipPath(clipPath);
            super.dispatchDraw(canvas);
            canvas.restoreToCount(count);
        } else {
            super.dispatchDraw(canvas);
        }
    }
}
