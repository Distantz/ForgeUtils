/**
 * 
 * 
*  {
    label: "[OptionsMenu_Controls_Coaster_Edit_AdditiveTrackSelection]",
    inputName: NewtonInput.EditorsAdditiveTrackSelectModifier,
    icon: "mouseL",
    hideHoldIndicator: true,
    canEdit: true,
    holdTime: 0.01,
    },
 */

import { OptionsMenuModel } from "/js/project/modules/options/data/OptionsMenuModel.js";
import { NewtonRebindingInputs } from "/js/project/utils/NewtonInput.js";

OptionsMenuModel.__ForgeUtils_appendedGroups = [];
export function AddKeyboardGroups(groups) {
  console.log("appending group" + groups);
  OptionsMenuModel.__ForgeUtils_appendedGroups.push(groups);

  groups.items.map((item) => {
    if (item.inputName) {
      const itemInputName = item.inputName;
      console.log("iteminputname" + typeof itemInputName);
      if (NewtonRebindingInputs[itemInputName] === undefined)
        NewtonRebindingInputs[itemInputName] = itemInputName;
    }
  });
}

if (!OptionsMenuModel.__ForgeUtils_GroupsHooked) {
  OptionsMenuModel.__ForgeUtils_GroupsHooked = true;
  const originalMethod = OptionsMenuModel.getKeyboardControlsData;

  OptionsMenuModel.getKeyboardControlsData = function () {
    const groups = originalMethod.call();
    console.log(groups);
    groups.push(...OptionsMenuModel.__ForgeUtils_appendedGroups);
    
    console.log(groups);
    return groups;
  };
}
