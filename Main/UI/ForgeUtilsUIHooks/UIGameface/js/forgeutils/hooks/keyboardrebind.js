import { OptionsMenuModel } from "/js/project/modules/options/data/OptionsMenuModel.js";
import { NewtonRebindingInputs } from "/js/project/utils/NewtonInput.js";

OptionsMenuModel.__ForgeUtils_appendedGroups = [];
export function AddKeyboardGroups(groups) {
  OptionsMenuModel.__ForgeUtils_appendedGroups.push(groups);

  groups.items.map((item) => {
    if (item.inputName) {
      const itemInputName = item.inputName;
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
    groups.push(...OptionsMenuModel.__ForgeUtils_appendedGroups);
    return groups;
  };
}
