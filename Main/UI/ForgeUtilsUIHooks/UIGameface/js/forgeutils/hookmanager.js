import * as Engine from "/js/common/core/Engine.js";
import "/js/forgeutils/printhelper.js";

const moduleHooks = new Map();

export function onAddModuleHook(className, hookHandlerFile) {
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
            console.log(`Added hook ${hookHandlerFile} for element ${className}`)
        })
        .catch(err => {
            console.error(`Failed to load UI hook handler "${hookHandlerFile}":`, err);
        });
}

export function triggerModuleHooks(className, originalMethod, nodeName, attributes, ...children) {
    const handlers = moduleHooks.get(className) ?? [];
    const chain = handlers.reduceRight(
        (next, handler) => {
            return (n, a, ...c) => handler(next, n, a, ...c);
        },
        (n, a, ...c) => originalMethod(n, a, ...c)
    );
    return chain(nodeName, attributes, ...children);
}

export function hasHooks(className) {
    return moduleHooks.has(className);
}

Engine.addListener("ForgeUtils_AddModuleHook", onAddModuleHook);
onAddModuleHook(
    "div",
    "/js/hooks/forgeutils/hudBottomBarHook.js"
);