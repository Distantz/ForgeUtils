import * as Engine from "/js/common/core/Engine.js";
import "/js/forgeutils/printhelper.js";
let keyboardRebind;
const moduleHooks = new Map();

export function onAddImportHook(importedFile) {
  import(importedFile)
    .then((module) => {
      console.log(`Added hook ${importedFile}!`);
    })
    .catch((err) => {
      console.error(`Failed to load hooked import "${importedFile}":`, err);
    });
}

export function onAddElementHook(className, hookHandlerFile) {
  import(hookHandlerFile)
    .then((module) => {
      if (typeof module.OnHook !== "function") {
        console.warn(`Module "${hookHandlerFile}" does not export an OnHook function.`);
        return;
      }
      if (!moduleHooks.has(className)) {
        moduleHooks.set(className, []);
      }
      moduleHooks.get(className).push(module.OnHook);
      console.log(`Added hook ${hookHandlerFile} for element ${className}`);
    })
    .catch((err) => {
      console.error(
        `Failed to load UI hook handler "${hookHandlerFile}":`,
        err,
      );
    });
}

export function onAddKeyboardGroups(groups) {
  if (keyboardRebind == undefined) {
    import("/js/forgeutils/hooks/keyboardrebind.js")
      .then((module) => {
        keyboardRebind = module;
        console.log(`Added hook /js/forgeutils/hooks/keyboardrebind.js!`);
        keyboardRebind.AddKeyboardGroups(groups);
      })
      .catch((err) => {
        console.error(`Failed to load hooked import /js/forgeutils/hooks/keyboardrebind.js:`, err,);
      });
  }
  if (keyboardRebind !== undefined) {
    keyboardRebind.AddKeyboardGroups(groups);
  }
}

export function triggerModuleHooks(className,originalMethod,nodeName,attributes,...children) 
{
  const handlers = moduleHooks.get(className) ?? [];
  const chain = handlers.reduceRight(
    (next, handler) => {
      return (n, a, ...c) => handler(next, n, a, ...c);
    },
    (n, a, ...c) => originalMethod(n, a, ...c),
  );
  return chain(nodeName, attributes, ...children);
}

export function hasHooks(className) {
  return moduleHooks.has(className);
}

// Add
Engine.whenReady.then(async () => {
  Engine.addListener("ForgeUtils_AddElementHook", onAddElementHook);
  Engine.addListener("ForgeUtils_AddImportHook", onAddImportHook);
  Engine.addListener("ForgeUtils_AddKeyboardGroups", onAddKeyboardGroups);
});
