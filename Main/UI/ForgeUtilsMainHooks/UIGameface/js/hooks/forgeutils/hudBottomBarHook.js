import { StatusControlButton } from '/js/project/modules/statusBar/components/StatusControlsButton.js';
import * as preact from '/js/common/lib/preact.js';
import { classNames } from '/js/common/lib/classnames.js';
import { Tooltip } from '/js/project/components/Tooltip.js';

const tooltipFunc = (target) => preact.h(
    Tooltip,
    {
        target: target,
        label: '[ForgeUtilsModButton]',
        // inputName: NewtonInput.EditorsToggleWeatherReportVisibility,
        modifiers: 'inputIconOnRight wide'
    }
);

/**
 * This hook adds the Mod Bar to the bottom row of the main game UI HUD.
 * 
 * @param {Function} next - The next hook in the chain
 * @param {string} nodeName - The type of element
 * @param {Object} attributes - The props/attributes of the element
 * @param {...any} children - The child elements
 */
export function OnHook(next, nodeName, attributes, ...children) {
    if (nodeName != "div") {
        return next(nodeName, attributes, ...children);
    }

    if (attributes == undefined) {
        return next(nodeName, attributes, ...children);
    }

    if (attributes.className == undefined) {
        return next(nodeName, attributes, ...children);
    }

    if (attributes.className != "StatusControls_root") {
        return next(nodeName, attributes, ...children);
    }

    console.log("Found StatusControls_root!");
    console.log(children);

    let modButton = preact.h(
        "div",
        { className: classNames('StatusControls_content', 'optionMenu') },
        preact.h(
            StatusControlButton,
            {
                icon: '/img/icons/crossedTools.svg',
                tooltip: tooltipFunc
            }
        )
    );

    // Injecting second child
    let newChildren = [modButton, ...children];
    console.log("New children:");
    console.log(newChildren);

    return next(nodeName, attributes, ...newChildren);
}