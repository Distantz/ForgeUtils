import * as Engine from "/js/common/core/Engine.js";
Engine.whenReady.then(
    async () => {

        // Enable logging
        if (!Engine.isCoherentPlayer()) {
            let _isLogging = false;

            const stringify = (a) => {
                if (a === null) return 'null';
                if (a === undefined) return 'undefined';
                if (typeof a === 'function') return a.toString();
                if (typeof a === 'object') {
                    try {
                        return JSON.stringify(a, (key, val) =>
                            typeof val === 'function' ? val.toString() : val
                        );
                    } catch {
                        return Object.prototype.toString.call(a);
                    }
                }
                return String(a);
            };

            const makeLogger = (original, eventName) => (...args) => {
                if (_isLogging) return original(...args);
                _isLogging = true;
                Engine.sendEvent(eventName, args.map(stringify).join(' '));
                original(...args);
                _isLogging = false;
            };

            console.debug = makeLogger(console.debug, 'ForgeUtils_LogDebug');
            console.log = makeLogger(console.log, 'ForgeUtils_LogInfo');
            console.info = makeLogger(console.info, 'ForgeUtils_LogInfo');
            console.warn = makeLogger(console.warn, 'ForgeUtils_LogWarn');
            console.error = makeLogger(console.error, 'ForgeUtils_LogError');

            console.log("Set up Preact printing hook.");
        }
    }
);