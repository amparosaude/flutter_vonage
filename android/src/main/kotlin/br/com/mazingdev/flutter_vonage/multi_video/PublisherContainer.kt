package br.com.mazingdev.flutter_vonage.multi_video

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import androidx.constraintlayout.widget.ConstraintLayout
import android.widget.FrameLayout
import br.com.mazingdev.flutter_vonage.R

class PublisherContainer @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0,
    defStyleRes: Int = 0
) : ConstraintLayout(context, attrs, defStyle, defStyleRes) {

    var mainContainer: ConstraintLayout
        private set

    init {
        val view = LayoutInflater.from(context).inflate(R.layout.publisher_video, this, true)
        mainContainer = view.findViewById(R.id.publisher_container)
    }
}