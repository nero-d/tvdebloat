package com.appletv.launcher;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Outline;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewOutlineProvider;
import android.widget.ImageView;

/**
 * Custom ImageView that clips banners and icons to smooth 18dp rounded corners,
 * matching Apple TV 4K tile specs and preventing square corners from leaking past rounded containers.
 */
public class RoundedImageView extends ImageView {
    private final Path clipPath = new Path();
    private final RectF rectF = new RectF();
    private float cornerRadius = 0f;

    public RoundedImageView(Context context) {
        super(context);
        init(context);
    }

    public RoundedImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public RoundedImageView(Context context, AttributeSet attrs, int defStyleAttr) {
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
}
