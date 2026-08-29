package com.flowauto.generator

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class FlowAccessibilityService :
    AccessibilityService() {

    override fun onAccessibilityEvent(
        event: AccessibilityEvent?
    ) {

        if (event == null) return

        val root = rootInActiveWindow
            ?: return

        /*
         * Google Flow automation
         *
         * Здесь позже:
         *
         * PROMPT
         * GENERATE
         * WAIT
         * DOWNLOAD
         * NEXT
         */

        findPromptField(root)
    }

    private fun findPromptField(
        root: AccessibilityNodeInfo
    ): AccessibilityNodeInfo? {

        val possibleNames = listOf(
            "Prompt",
            "Describe your image",
            "Enter a prompt"
        )

        for (name in possibleNames) {

            val nodes =
                root.findAccessibilityNodeInfosByText(
                    name
                )

            if (nodes.isNotEmpty()) {
                return nodes.first()
            }
        }

        return null
    }

    override fun onInterrupt() {
    }
    }
