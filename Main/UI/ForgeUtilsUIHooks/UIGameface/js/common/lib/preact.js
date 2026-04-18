import * as Engine from '/js/common/core/Engine.js';
import * as Profile from '/js/common/core/Profile.js';
import { triggerModuleHooks, hasHooks } from '/js/forgeutils/hookmanager.js';
import '/js/forgeutils/printhelper.js';


let extend = Object.assign;
let defer = Promise.resolve().then.bind(Promise.resolve());
export const options = {};
export class Component {
    static defaultProps;
    base;
    nextBase;
    prevProps;
    props;
    _dirty;
    _disable;
    _component;
    _parentComponent;
    __key;
    __name;
    __ref;
    prevContext;
    context;
    state;
    prevState;
    constructor(props, context) {
        this._dirty = 1;
        this.props = props;
        this.context = context;
        this.state = {};
        this.__name = this.constructor.name;
    }
    setState(state) {
        if (!this.prevState)
            this.prevState = this.state;
        this.state = extend(extend({}, this.state), state);
        enqueueRender(this);
    }
    forceUpdate() {
        renderComponent(this, 2);
    }
    enqueueForceUpdate() {
        enqueueForceRender(this);
    }
}
let NULL_RENDER_FUNC = () => null;
class FunctionalComponent extends Component {
    render = NULL_RENDER_FUNC;
}
let EMPTY_CHILDREN = [];
let stack = [];

//
// FORGEUTILS START HOOK
//

function getSaveHtmlType(name) {
    if (typeof (name) == 'string') {
        return name;
    }
    return name.name;
}

export function testForgeUtils() {
    return true;
}

export function h(nodeName, attributes, ...hookArgs) {
    // This is our hooking logic.
    // This calls our hooks if they exist.
    const preactTypeStr = getSaveHtmlType(nodeName);
    if (hasHooks(preactTypeStr)) {
        return triggerModuleHooks(preactTypeStr, _h, nodeName, attributes, ...hookArgs);
    }

    return _h(nodeName, attributes, ...hookArgs);
}

// Internal h implementation. Renamed from the original exported
function _h(nodeName, attributes) {
    let children = EMPTY_CHILDREN;
    let lastSimple;
    let child;
    let simple;
    for (let i = arguments.length; i-- > 2;) {
        stack.push(arguments[i]);
    }
    if (attributes && attributes.children != null) {
        if (!stack.length)
            stack.push(attributes.children);
        delete attributes.children;
    }
    while (stack.length) {
        if ((child = stack.pop()) && child.pop !== undefined) {
            for (let i = child.length; i--;) {
                stack.push(child[i]);
            }
        }
        else {
            if (typeof child === 'boolean')
                child = null;
            if (simple = typeof nodeName !== 'function') {
                if (child == null)
                    child = '';
                else if (typeof child === 'number')
                    child = String(child);
                else if (typeof child !== 'string')
                    simple = false;
            }
            if (simple && lastSimple)
                children[children.length - 1] += child;
            else if (children === EMPTY_CHILDREN)
                children = [child];
            else
                children.push(child);
            lastSimple = simple;
        }
    }
    const p = {
        nodeName,
        children,
        attributes: (attributes == null ? undefined : attributes),
        key: attributes == null ? undefined : attributes.key,
    };
    return p;
}

//
// FORGEUTILS END HOOK
//

export function render(vnode, parent, merge, context = {}) {
    return diff(merge, vnode, context, false, parent, false);
}
export function setComponentProps(component, props, renderMode, context, mountAll) {
    if (component._disable)
        return;
    component._disable = true;
    component.__ref = props.ref;
    component.__key = props.key;
    delete props.ref;
    delete props.key;
    if (!component.base || mountAll) {
        if (component.componentWillMount) {
            component.componentWillMount(props, context);
        }
    }
    else if (component.componentWillReceiveProps) {
        component.componentWillReceiveProps(props, context);
    }
    if (context && context !== component.context) {
        if (!component.prevContext)
            component.prevContext = component.context;
        component.context = context;
    }
    if (!component.prevProps)
        component.prevProps = component.props;
    component.props = props;
    component._disable = false;
    if (renderMode !== 0) {
        if (!component.base) {
            renderComponent(component, 1, mountAll);
        }
        else {
            enqueueRender(component);
        }
    }
    applyRef(component.__ref, component);
}
let items = [];
function enqueueRender(component) {
    if (component._dirty == 0 && (component._dirty = 1) && items.push(component) == 1) {
        defer(rerender);
    }
}
function enqueueForceRender(component) {
    if (component._dirty != 2 && (component._dirty = 2) && items.push(component) == 1) {
        defer(rerender);
    }
}
export function rerender() {
    if (Engine.isCoherentPlayer()) {
        let p;
        while (p = items.pop()) {
            if (p._dirty != 0)
                renderComponent(p, p._dirty);
        }
    }
    else {
        let p;
        try {
            while (p = items.pop()) {
                if (p._dirty != 0)
                    renderComponent(p, p._dirty);
            }
        }
        catch (e) {
            if (p) {
                console.log("UI Error while rendering " + p.__name);
            }
            console.log(e.stack);
            throw (e);
        }
    }
}
function applyRef(ref, value) {
    if (ref) {
        ref(value);
    }
}
function isSameNodeType(node, vnode, hydrating) {
    if (typeof vnode === 'string' || typeof vnode === 'number') {
        return node.splitText !== undefined;
    }
    if (typeof vnode.nodeName === 'string') {
        return !node._componentConstructor && node.normalizedNodeName === vnode.nodeName;
    }
    return hydrating || node._componentConstructor === vnode.nodeName;
}
function getNodeProps(vnode) {
    const props = extend({}, vnode.attributes);
    props.children = vnode.children;
    const defaultProps = vnode.nodeName.defaultProps;
    if (defaultProps !== undefined) {
        for (let i in defaultProps) {
            if (props[i] === undefined) {
                props[i] = defaultProps[i];
            }
        }
    }
    return props;
}
function generateEventNameLUT() {
    let eventNames = [
        'onClick', 'onMouseDown', 'onMouseEnter', 'onMouseLeave', 'onLoad', 'onFocus', 'onBlur', 'onChange',
        'onInput', 'onKeyDown', 'onKeyPress', 'onKeyUp', 'onClick', 'onDoubleClick', 'onDrag', 'onDragEnd',
        'onDragEnter', 'onDragExit', 'onDragLeave', 'onDragOver', 'onDragStart', 'onDrop', 'onMouseMove',
        'onMouseOut', 'onMouseOver', 'onMouseUp', 'onSelect', 'onScroll', 'onWheel', 'onAnimationStart',
        'onAnimationEnd', 'onAnimationIteration', 'onTransitionEnd',
    ];
    let lut = {};
    for (let eventName of eventNames) {
        lut[eventName] = eventName.substring(2).toLowerCase();
    }
    return lut;
}
const EVENT_NAME_LUT = generateEventNameLUT();
function eventProxy(e) {
    if (this._listeners) {
        let callback = this._listeners[e.type];
        if (callback) {
            return callback(e);
        }
    }
}
let mounts = [];
let diffLevel = 0;
function flushMounts() {
    let c;
    while (c = mounts.shift()) {
        if (c.componentDidMount) {
            c.componentDidMount();
        }
    }
}
function diff(dom, vnode, context, mountAll, parent, componentRoot) {
    diffLevel++;
    let ret = idiff(dom, vnode, context, mountAll, componentRoot);
    if (parent && ret.parentNode !== parent && parent !== ret)
        parent.appendChild(ret);
    if (!--diffLevel) {
        if (!componentRoot)
            flushMounts();
    }
    return ret;
}
function idiff(dom, vnode, context, mountAll, componentRoot) {
    let out = dom;
    let typeofvnode = typeof vnode;
    if (vnode == null || typeofvnode === 'boolean')
        vnode = '';
    if (typeofvnode === 'string' || typeofvnode === 'number') {
        if (dom && dom.splitText !== undefined && dom.parentNode && (!dom._component || componentRoot)) {
            if (dom.nodeValue != vnode) {
                dom.nodeValue = vnode;
            }
        }
        else {
            out = document.createTextNode(vnode);
            if (dom) {
                if (dom.parentNode)
                    dom.parentNode.replaceChild(out, dom);
                recollectNodeTree(dom, true);
            }
        }
        out.__p_ = true;
        return out;
    }
    let vnodeName = vnode.nodeName;
    if (typeof vnodeName === 'function') {
        return buildComponentFromVNode(dom, vnode, context, mountAll);
    }
    vnodeName = String(vnodeName);
    if (!dom || dom.normalizedNodeName !== vnodeName) {
        out = document.createElement(vnodeName);
        out.normalizedNodeName = vnodeName;
        if (dom) {
            while (dom.firstChild) {
                out.appendChild(dom.firstChild);
            }
            if (dom.parentNode)
                dom.parentNode.replaceChild(out, dom);
            recollectNodeTree(dom, true);
        }
    }
    let firstChild = out.firstChild;
    let props = out.__p_;
    let vchildren = vnode.children;
    if (props == null) {
        props = out.__p_ = {};
    }
    if (vchildren && vchildren.length === 1 && typeof vchildren[0] === 'string' && firstChild != null && firstChild.splitText !== undefined && firstChild.nextSibling == null) {
        if (firstChild.nodeValue != vchildren[0]) {
            firstChild.nodeValue = vchildren[0];
        }
    }
    else if (vchildren && vchildren.length || firstChild != null) {
        let isHydrating = props.dangerouslySetInnerHTML != null;
        const originalChildren = out.childNodes;
        const children = [];
        const keyed = {};
        let keyedLen = 0;
        let min = 0;
        const len = originalChildren.length;
        let childrenLen = 0;
        const vlen = vchildren ? vchildren.length : 0;
        let child;
        if (len !== 0) {
            for (let i = 0; i < len; i++) {
                let _child = originalChildren[i];
                let props = _child.__p_;
                let key = vlen && props ? _child._component ? _child._component.__key : props.key : null;
                if (key != null) {
                    keyedLen++;
                    keyed[key] = _child;
                }
                else if (props || (_child.splitText !== undefined ? isHydrating ? _child.nodeValue.trim() : true : isHydrating)) {
                    children[childrenLen++] = _child;
                }
            }
        }
        if (vlen !== 0) {
            for (let i = 0; i < vlen; i++) {
                let vchild = vchildren[i];
                child = null;
                const _key = vchild.key;
                if (_key != null) {
                    if (keyedLen && keyed[_key] !== undefined) {
                        child = keyed[_key];
                        keyed[_key] = undefined;
                        keyedLen--;
                    }
                }
                else if (min < childrenLen) {
                    for (let j = min; j < childrenLen; j++) {
                        let c;
                        if (children[j] !== undefined && isSameNodeType(c = children[j], vchild, isHydrating)) {
                            child = c;
                            children[j] = undefined;
                            if (j === childrenLen - 1)
                                childrenLen--;
                            if (j === min)
                                min++;
                            break;
                        }
                    }
                }
                child = idiff(child, vchild, context, mountAll);
                let f = originalChildren[i];
                if (child && child !== dom && child !== f) {
                    if (f == null) {
                        out.appendChild(child);
                    }
                    else if (child === f.nextSibling) {
                        f.parentNode && f.parentNode.removeChild(f);
                    }
                    else {
                        out.insertBefore(child, f);
                    }
                }
            }
        }
        if (keyedLen) {
            for (let _i2 in keyed) {
                const item = keyed[_i2];
                if (item !== undefined)
                    recollectNodeTree(keyed[_i2], false);
            }
        }
        while (min <= childrenLen) {
            if ((child = children[childrenLen--]) !== undefined)
                recollectNodeTree(child, false);
        }
    }
    let attrs = vnode.attributes;
    for (let name in props) {
        if (!(attrs && attrs[name] != null) && props[name] != null) {
            let eventName;
            let old = props[name];
            props[name] = undefined;
            if (name === 'className') {
                out.className = '';
            }
            else if (name === 'style') {
                out.style.cssText = '';
            }
            else if (eventName = EVENT_NAME_LUT[name]) {
                if (out._listeners && out._listeners[eventName]) {
                    out.removeEventListener(eventName, eventProxy);
                    (out._listeners || (out._listeners = {}))[eventName] = undefined;
                }
            }
            else if (name === 'dangerouslySetInnerHTML') {
                out.innerHTML = '';
            }
            else if (name === 'key') {
            }
            else if (name === 'ref') {
                applyRef(old, null);
            }
            else if (name in out.attributes) {
                out.setAttribute(name, '');
            }
            else if (name in out) {
                out[name] = '';
            }
        }
    }
    for (let name in attrs) {
        if (name !== 'children' && name !== 'innerHTML' && (!(name in props) || attrs[name] !== props[name])) {
            let old = props[name];
            let value = props[name] = attrs[name];
            props[name] = value;
            let eventName;
            if (name === 'className') {
                out.className = value || '';
            }
            else if (name === 'style') {
                out.style.cssText = '';
                if (value) {
                    for (let i in value) {
                        out.style[i] = value[i];
                    }
                }
            }
            else if (eventName = EVENT_NAME_LUT[name]) {
                if (value) {
                    if (!old)
                        out.addEventListener(eventName, eventProxy);
                    (out._listeners || (out._listeners = {}))[eventName] = value;
                }
                else if (out._listeners && out._listeners[eventName]) {
                    out.removeEventListener(eventName, eventProxy);
                    out._listeners[eventName] = undefined;
                }
            }
            else if (name === 'dangerouslySetInnerHTML') {
                if (value)
                    out.innerHTML = value.__html || '';
            }
            else if (name === 'key') {
            }
            else if (name === 'ref') {
                applyRef(old, null);
                applyRef(value, out);
            }
            else if (name in out.attributes) {
                out.setAttribute(name, value);
            }
            else if (name in out) {
                out[name] = value == null ? '' : value;
            }
        }
    }
    return out;
}
function recollectNodeTree(node, unmountOnly) {
    const component = node._component;
    if (component) {
        unmountComponent(component);
    }
    else {
        if (node.__p_ != null)
            applyRef(node.__p_.ref, null);
        if (unmountOnly === false || node.__p_ == null) {
            node.parentNode && node.parentNode.removeChild(node);
        }
        removeChildren(node);
    }
}
function removeChildren(node) {
    node = node.lastChild;
    while (node) {
        const next = node.previousSibling;
        recollectNodeTree(node, true);
        node = next;
    }
}
function createComponent(Ctor, props, context) {
    let inst;
    if (Ctor.prototype && Ctor.prototype.render) {
        inst = new Ctor(props, context);
    }
    else {
        inst = new FunctionalComponent(props, context);
        inst.constructor = Ctor;
        inst.__name = Ctor.name;
        inst.render = doRender;
    }
    return inst;
}
// @ts-ignore
function doRender(props, state, context) {
    return this.constructor(props, context);
}
function renderComponent(component, renderMode, mountAll, isChild) {
    if (component._disable)
        return;
    Profile.push(component.__name);
    const isUpdate = component.base != null;
    let skip = false;
    const props = component.props;
    const state = component.state;
    let context = component.context;
    const previousProps = component.prevProps || props;
    const previousState = component.prevState || state;
    const previousContext = component.prevContext || context;
    const nextBase = component.nextBase;
    const initialBase = component.base || nextBase;
    const initialChildComponent = component._component;
    if (isUpdate) {
        component.props = previousProps;
        component.state = previousState;
        component.context = previousContext;
        if (renderMode !== 2) {
            if (component.shouldComponentUpdate !== undefined) {
                skip = component.shouldComponentUpdate(props, state, context) === false;
            }
            else {
                skip = true;
                for (let key in props) {
                    if (previousProps[key] != props[key]) {
                        skip = false;
                        break;
                    }
                }
                if (skip) {
                    for (let key in state) {
                        if (previousState[key] != state[key]) {
                            skip = false;
                            break;
                        }
                    }
                }
                if (skip) {
                    for (let key in context) {
                        if (previousContext[key] != context[key]) {
                            skip = false;
                            break;
                        }
                    }
                }
            }
        }
        if ((!skip || renderMode == 2) && component.componentWillUpdate) {
            component.componentWillUpdate(props, state, context);
        }
        component.props = props;
        component.state = state;
        component.context = context;
    }
    component.prevProps = component.prevState = component.prevContext = component.nextBase = undefined;
    component._dirty = 0;
    if (!skip) {
        Profile.push(component.__name + ":render()");
        const rendered = component.render(props, state, context);
        Profile.pop();
        if (rendered && props.id) {
            if (rendered.attributes) {
                rendered.attributes.id = props.id;
            }
            else {
                rendered.attributes = { id: props.id };
            }
        }
        let autoContext = null;
        if (component.props.context) {
            autoContext = { dataStoreContext: component.props.context };
        }
        if (component.props.visible != null) {
            autoContext = autoContext || {};
            // @ts-ignore
            autoContext.visible = component.props.visible;
        }
        if (component.props.moduleName != null) {
            autoContext = autoContext || {};
            // @ts-ignore
            autoContext.moduleName = component.props.moduleName;
        }
        if (component.props.modulePurpose != null) {
            autoContext = autoContext || {};
            // @ts-ignore
            autoContext.modulePurpose = component.props.modulePurpose;
        }
        if (component.props.componentName != null) {
            autoContext = autoContext || {};
            // @ts-ignore
            autoContext.componentName = component.props.componentName;
        }
        context = extend({}, context);
        if (autoContext) {
            context = extend(context, autoContext);
        }
        if (component.getChildContext) {
            context = extend(context, component.getChildContext());
        }
        const childComponent = rendered && rendered.nodeName;
        let toUnmount;
        let base;
        let inst;
        if (typeof childComponent === 'function') {
            let childProps = getNodeProps(rendered);
            inst = initialChildComponent;
            if (inst && inst.constructor === childComponent && childProps.key == inst.__key) {
                setComponentProps(inst, childProps, 1, context, false);
            }
            else {
                toUnmount = inst;
                component._component = inst = createComponent(childComponent, childProps, context);
                inst.nextBase = inst.nextBase || nextBase;
                inst._parentComponent = component;
                setComponentProps(inst, childProps, 0, context, false);
                renderComponent(inst, 1, mountAll, true);
            }
            base = inst.base;
        }
        else {
            let cbase = initialBase;
            toUnmount = initialChildComponent;
            if (toUnmount) {
                cbase = component._component = undefined;
            }
            if (initialBase || renderMode === 1) {
                if (cbase)
                    cbase._component = undefined;
                base = diff(cbase, rendered, context, mountAll || !isUpdate, initialBase && initialBase.parentNode, true);
            }
        }
        if (initialBase && base !== initialBase && inst !== initialChildComponent) {
            const baseParent = initialBase.parentNode;
            if (baseParent && base !== baseParent) {
                baseParent.insertBefore(base, initialBase);
                baseParent.removeChild(initialBase);
                if (!toUnmount) {
                    initialBase._component = undefined;
                    recollectNodeTree(initialBase, false);
                }
            }
        }
        if (toUnmount) {
            unmountComponent(toUnmount);
        }
        component.base = base;
        if (base && !isChild) {
            let componentRef = component;
            let t = component;
            while (t = t._parentComponent) {
                (componentRef = t).base = base;
            }
            base._component = componentRef;
            base._componentConstructor = componentRef.constructor;
        }
    }
    if (!isUpdate || mountAll) {
        mounts.push(component);
    }
    else if (!skip) {
        if (component.componentDidUpdate) {
            component.componentDidUpdate(previousProps, previousState, previousContext);
        }
        if (options.afterUpdate) {
            options.afterUpdate(component, previousProps, previousState, previousContext);
        }
    }
    if (!diffLevel && !isChild) {
        flushMounts();
    }
    Profile.pop();
}
function buildComponentFromVNode(dom, vnode, context, mountAll) {
    let c = dom && dom._component;
    const originalComponent = c;
    let oldDom = dom;
    const isDirectOwner = c && dom._componentConstructor === vnode.nodeName;
    let isOwner = isDirectOwner;
    const props = getNodeProps(vnode);
    let retDom;
    while (c && !isOwner && (c = c._parentComponent)) {
        isOwner = c.constructor === vnode.nodeName;
    }
    if (c && isOwner && (!mountAll || c._component)) {
        setComponentProps(c, props, 3, context, mountAll);
        retDom = c.base;
    }
    else {
        if (originalComponent && !isDirectOwner) {
            unmountComponent(originalComponent);
            retDom = oldDom = undefined;
        }
        c = createComponent(vnode.nodeName, props, context);
        if (dom && !c.nextBase) {
            c.nextBase = dom;
            oldDom = undefined;
        }
        setComponentProps(c, props, 1, context, mountAll);
        retDom = c.base;
        if (oldDom && retDom !== oldDom) {
            oldDom._component = undefined;
            recollectNodeTree(oldDom, false);
        }
    }
    return retDom;
}
function unmountComponent(component) {
    const base = component.base;
    component._disable = true;
    if (component.componentWillUnmount)
        component.componentWillUnmount();
    component.base = undefined;
    const inner = component._component;
    if (inner) {
        unmountComponent(inner);
    }
    else if (base) {
        if (base.__p_ != null)
            applyRef(base.__p_.ref, null);
        component.nextBase = base;
        base.parentNode && base.parentNode.removeChild(base);
        base.style.cssText = '';
        removeChildren(base);
    }
    applyRef(component.__ref, null);
}