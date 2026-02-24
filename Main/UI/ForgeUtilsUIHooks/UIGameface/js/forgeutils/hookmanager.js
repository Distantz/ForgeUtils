import * as Engine from "/js/common/core/Engine.js";
import "/js/forgeutils/printhelper.js";

const moduleHooks = new Map();

function onAddModuleHook(className, hookHandlerFile) {
    import(hookHandlerFile)
        .then(module => {
            if (typeof module.OnHook !== 'function') {
                console.warn(`Module "${hookHandlerFile}" does not export an OnHook function.`);
                return;
            }
            if (!moduleHooks.has(className)) {
                moduleHooks.set(className, []);
            }
            moduleHooks.get(className).push(module.OnHook);
        })
        .catch(err => {
            console.error(`Failed to load UI hook handler "${hookHandlerFile}":`, err);
        });
}

export function triggerModuleHooks(className, originalMethod, nodeName, attributes, ...children) {
    const handlers = moduleHooks.get(className) ?? [];
    const chain = handlers.reduceRight(
        (next, handler) => {
            return () => handler(next, nodeName, attributes, ...children);
        },
        () => originalMethod(nodeName, attributes, ...children)
    );
    return chain();
}

export function hasHooks(className) {
    return moduleHooks.has(className);
}

Engine.addListener("ForgeUtils_AddModuleHook", onAddModuleHook);