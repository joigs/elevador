function e(e,t,o){if("function"==typeof e?e===t:e.has(t))return arguments.length<3?t:o;throw new TypeError("Private element is not present on this object")}function t(e,t){if(t.has(e))throw new TypeError("Cannot initialize the same private elements twice on an object")}function o(t,o){return t.get(e(t,o))}function n(e,o,n){t(e,o),o.set(e,n)}function s(t,o,n){return t.set(e(t,o),n),n}const a=100;
/** @type {GlobalState} */const r={};const i=()=>{if(r.previousActiveElement instanceof HTMLElement){r.previousActiveElement.focus();r.previousActiveElement=null}else document.body&&document.body.focus()};
/**
 * Restore previous active (focused) element
 *
 * @param {boolean} returnFocus
 * @returns {Promise<void>}
 */const l=e=>new Promise((t=>{if(!e)return t();const o=window.scrollX;const n=window.scrollY;r.restoreFocusTimeout=setTimeout((()=>{i();t()}),a);window.scrollTo(o,n)}));const c="swal2-";
/**
 * @typedef {Record<SwalClass, string>} SwalClasses
 */
/**
 * @typedef {'success' | 'warning' | 'info' | 'question' | 'error'} SwalIcon
 * @typedef {Record<SwalIcon, string>} SwalIcons
 */
/** @type {SwalClass[]} */const d=["container","shown","height-auto","iosfix","popup","modal","no-backdrop","no-transition","toast","toast-shown","show","hide","close","title","html-container","actions","confirm","deny","cancel","default-outline","footer","icon","icon-content","image","input","file","range","select","radio","checkbox","label","textarea","inputerror","input-label","validation-message","progress-steps","active-progress-step","progress-step","progress-step-line","loader","loading","styled","top","top-start","top-end","top-left","top-right","center","center-start","center-end","center-left","center-right","bottom","bottom-start","bottom-end","bottom-left","bottom-right","grow-row","grow-column","grow-fullscreen","rtl","timer-progress-bar","timer-progress-bar-container","scrollbar-measure","icon-success","icon-warning","icon-info","icon-question","icon-error","draggable","dragging"];const u=d.reduce(((e,t)=>{e[t]=c+t;return e}),/** @type {SwalClasses} */{});
/** @type {SwalIcon[]} */const w=["success","warning","info","question","error"];const m=w.reduce(((e,t)=>{e[t]=c+t;return e}),/** @type {SwalIcons} */{});const p="SweetAlert2:";
/**
 * Capitalize the first letter of a string
 *
 * @param {string} str
 * @returns {string}
 */const h=e=>e.charAt(0).toUpperCase()+e.slice(1)
/**
 * Standardize console warnings
 *
 * @param {string | string[]} message
 */;const g=e=>{console.warn(`${p} ${typeof e==="object"?e.join(" "):e}`)};
/**
 * Standardize console errors
 *
 * @param {string} message
 */const f=e=>{console.error(`${p} ${e}`)};
/**
 * Private global state for `warnOnce`
 *
 * @type {string[]}
 * @private
 */const b=[];
/**
 * Show a console warning, but only if it hasn't already been shown
 *
 * @param {string} message
 */const v=e=>{if(!b.includes(e)){b.push(e);g(e)}};
/**
 * Show a one-time console warning about deprecated params/methods
 *
 * @param {string} deprecatedParam
 * @param {string?} useInstead
 */const y=function(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:null;v(`"${e}" is deprecated and will be removed in the next major release.${t?` Use "${t}" instead.`:""}`)};
/**
 * If `arg` is a function, call it (with no arguments or context) and return the result.
 * Otherwise, just pass the value through
 *
 * @param {Function | any} arg
 * @returns {any}
 */const k=e=>typeof e==="function"?e():e
/**
 * @param {any} arg
 * @returns {boolean}
 */;const x=e=>e&&typeof e.toPromise==="function"
/**
 * @param {any} arg
 * @returns {Promise<any>}
 */;const C=e=>x(e)?e.toPromise():Promise.resolve(e)
/**
 * @param {any} arg
 * @returns {boolean}
 */;const A=e=>e&&Promise.resolve(e)===e
/**
 * Gets the popup container which contains the backdrop and the popup itself.
 *
 * @returns {HTMLElement | null}
 */;const E=()=>document.body.querySelector(`.${u.container}`)
/**
 * @param {string} selectorString
 * @returns {HTMLElement | null}
 */;const $=e=>{const t=E();return t?t.querySelector(e):null};
/**
 * @param {string} className
 * @returns {HTMLElement | null}
 */const B=e=>$(`.${e}`);
/**
 * @returns {HTMLElement | null}
 */const L=()=>B(u.popup)
/**
 * @returns {HTMLElement | null}
 */;const P=()=>B(u.icon)
/**
 * @returns {HTMLElement | null}
 */;const S=()=>B(u["icon-content"])
/**
 * @returns {HTMLElement | null}
 */;const T=()=>B(u.title)
/**
 * @returns {HTMLElement | null}
 */;const O=()=>B(u["html-container"])
/**
 * @returns {HTMLElement | null}
 */;const j=()=>B(u.image)
/**
 * @returns {HTMLElement | null}
 */;const M=()=>B(u["progress-steps"])
/**
 * @returns {HTMLElement | null}
 */;const z=()=>B(u["validation-message"])
/**
 * @returns {HTMLButtonElement | null}
 */;const H=()=>/** @type {HTMLButtonElement} */$(`.${u.actions} .${u.confirm}`)
/**
 * @returns {HTMLButtonElement | null}
 */;const I=()=>/** @type {HTMLButtonElement} */$(`.${u.actions} .${u.cancel}`)
/**
 * @returns {HTMLButtonElement | null}
 */;const q=()=>/** @type {HTMLButtonElement} */$(`.${u.actions} .${u.deny}`)
/**
 * @returns {HTMLElement | null}
 */;const D=()=>B(u["input-label"])
/**
 * @returns {HTMLElement | null}
 */;const V=()=>$(`.${u.loader}`)
/**
 * @returns {HTMLElement | null}
 */;const N=()=>B(u.actions)
/**
 * @returns {HTMLElement | null}
 */;const _=()=>B(u.footer)
/**
 * @returns {HTMLElement | null}
 */;const F=()=>B(u["timer-progress-bar"])
/**
 * @returns {HTMLElement | null}
 */;const R=()=>B(u.close);const U='\n  a[href],\n  area[href],\n  input:not([disabled]),\n  select:not([disabled]),\n  textarea:not([disabled]),\n  button:not([disabled]),\n  iframe,\n  object,\n  embed,\n  [tabindex="0"],\n  [contenteditable],\n  audio[controls],\n  video[controls],\n  summary\n';
/**
 * @returns {HTMLElement[]}
 */const Y=()=>{const e=L();if(!e)return[];
/** @type {NodeListOf<HTMLElement>} */const t=e.querySelectorAll('[tabindex]:not([tabindex="-1"]):not([tabindex="0"])');const o=Array.from(t).sort(((e,t)=>{const o=parseInt(e.getAttribute("tabindex")||"0");const n=parseInt(t.getAttribute("tabindex")||"0");return o>n?1:o<n?-1:0}));
/** @type {NodeListOf<HTMLElement>} */const n=e.querySelectorAll(U);const s=Array.from(n).filter((e=>e.getAttribute("tabindex")!=="-1"));return[...new Set(o.concat(s))].filter((e=>we(e)))};
/**
 * @returns {boolean}
 */const W=()=>J(document.body,u.shown)&&!J(document.body,u["toast-shown"])&&!J(document.body,u["no-backdrop"]);
/**
 * @returns {boolean}
 */const Z=()=>{const e=L();return!!e&&J(e,u.toast)};
/**
 * @returns {boolean}
 */const K=()=>{const e=L();return!!e&&e.hasAttribute("data-loading")};
/**
 * Securely set innerHTML of an element
 * https://github.com/sweetalert2/sweetalert2/issues/1926
 *
 * @param {HTMLElement} elem
 * @param {string} html
 */const X=(e,t)=>{e.textContent="";if(t){const o=new DOMParser;const n=o.parseFromString(t,"text/html");const s=n.querySelector("head");s&&Array.from(s.childNodes).forEach((t=>{e.appendChild(t)}));const a=n.querySelector("body");a&&Array.from(a.childNodes).forEach((t=>{t instanceof HTMLVideoElement||t instanceof HTMLAudioElement?e.appendChild(t.cloneNode(true)):e.appendChild(t)}))}};
/**
 * @param {HTMLElement} elem
 * @param {string} className
 * @returns {boolean}
 */const J=(e,t)=>{if(!t)return false;const o=t.split(/\s+/);for(let t=0;t<o.length;t++)if(!e.classList.contains(o[t]))return false;return true};
/**
 * @param {HTMLElement} elem
 * @param {SweetAlertOptions} params
 */const G=(e,t)=>{Array.from(e.classList).forEach((o=>{Object.values(u).includes(o)||Object.values(m).includes(o)||Object.values(t.showClass||{}).includes(o)||e.classList.remove(o)}))};
/**
 * @param {HTMLElement} elem
 * @param {SweetAlertOptions} params
 * @param {string} className
 */const Q=(e,t,o)=>{G(e,t);if(!t.customClass)return;const n=t.customClass[/** @type {keyof SweetAlertCustomClass} */o];n&&(typeof n==="string"||n.forEach?ne(e,n):g(`Invalid type of customClass.${o}! Expected string or iterable object, got "${typeof n}"`))};
/**
 * @param {HTMLElement} popup
 * @param {import('./renderers/renderInput').InputClass | SweetAlertInput} inputClass
 * @returns {HTMLInputElement | null}
 */const ee=(e,t)=>{if(!t)return null;switch(t){case"select":case"textarea":case"file":return e.querySelector(`.${u.popup} > .${u[t]}`);case"checkbox":return e.querySelector(`.${u.popup} > .${u.checkbox} input`);case"radio":return e.querySelector(`.${u.popup} > .${u.radio} input:checked`)||e.querySelector(`.${u.popup} > .${u.radio} input:first-child`);case"range":return e.querySelector(`.${u.popup} > .${u.range} input`);default:return e.querySelector(`.${u.popup} > .${u.input}`)}};
/**
 * @param {HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement} input
 */const te=e=>{e.focus();if(e.type!=="file"){const t=e.value;e.value="";e.value=t}};
/**
 * @param {HTMLElement | HTMLElement[] | null} target
 * @param {string | string[] | readonly string[] | undefined} classList
 * @param {boolean} condition
 */const oe=(e,t,o)=>{if(e&&t){typeof t==="string"&&(t=t.split(/\s+/).filter(Boolean));t.forEach((t=>{Array.isArray(e)?e.forEach((e=>{o?e.classList.add(t):e.classList.remove(t)})):o?e.classList.add(t):e.classList.remove(t)}))}};
/**
 * @param {HTMLElement | HTMLElement[] | null} target
 * @param {string | string[] | readonly string[] | undefined} classList
 */const ne=(e,t)=>{oe(e,t,true)};
/**
 * @param {HTMLElement | HTMLElement[] | null} target
 * @param {string | string[] | readonly string[] | undefined} classList
 */const se=(e,t)=>{oe(e,t,false)};
/**
 * Get direct child of an element by class name
 *
 * @param {HTMLElement} elem
 * @param {string} className
 * @returns {HTMLElement | undefined}
 */const ae=(e,t)=>{const o=Array.from(e.children);for(let e=0;e<o.length;e++){const n=o[e];if(n instanceof HTMLElement&&J(n,t))return n}};
/**
 * @param {HTMLElement} elem
 * @param {string} property
 * @param {*} value
 */const re=(e,t,o)=>{o===`${parseInt(o)}`&&(o=parseInt(o));o||parseInt(o)===0?e.style.setProperty(t,typeof o==="number"?`${o}px`:o):e.style.removeProperty(t)};
/**
 * @param {HTMLElement | null} elem
 * @param {string} display
 */const ie=function(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:"flex";e&&(e.style.display=t)};
/**
 * @param {HTMLElement | null} elem
 */const le=e=>{e&&(e.style.display="none")};
/**
 * @param {HTMLElement | null} elem
 * @param {string} display
 */const ce=function(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:"block";e&&new MutationObserver((()=>{ue(e,e.innerHTML,t)})).observe(e,{childList:true,subtree:true})};
/**
 * @param {HTMLElement} parent
 * @param {string} selector
 * @param {string} property
 * @param {string} value
 */const de=(e,t,o,n)=>{
/** @type {HTMLElement | null} */
const s=e.querySelector(t);s&&s.style.setProperty(o,n)};
/**
 * @param {HTMLElement} elem
 * @param {any} condition
 * @param {string} display
 */const ue=function(e,t){let o=arguments.length>2&&arguments[2]!==void 0?arguments[2]:"flex";t?ie(e,o):le(e)};
/**
 * borrowed from jquery $(elem).is(':visible') implementation
 *
 * @param {HTMLElement | null} elem
 * @returns {boolean}
 */const we=e=>!!(e&&(e.offsetWidth||e.offsetHeight||e.getClientRects().length))
/**
 * @returns {boolean}
 */;const me=()=>!we(H())&&!we(q())&&!we(I())
/**
 * @param {HTMLElement} elem
 * @returns {boolean}
 */;const pe=e=>!!(e.scrollHeight>e.clientHeight)
/**
 * borrowed from https://stackoverflow.com/a/46352119
 *
 * @param {HTMLElement} elem
 * @returns {boolean}
 */;const he=e=>{const t=window.getComputedStyle(e);const o=parseFloat(t.getPropertyValue("animation-duration")||"0");const n=parseFloat(t.getPropertyValue("transition-duration")||"0");return o>0||n>0};
/**
 * @param {number} timer
 * @param {boolean} reset
 */const ge=function(e){let t=arguments.length>1&&arguments[1]!==void 0&&arguments[1];const o=F();if(o&&we(o)){if(t){o.style.transition="none";o.style.width="100%"}setTimeout((()=>{o.style.transition=`width ${e/1e3}s linear`;o.style.width="0%"}),10)}};const fe=()=>{const e=F();if(!e)return;const t=parseInt(window.getComputedStyle(e).width);e.style.removeProperty("transition");e.style.width="100%";const o=parseInt(window.getComputedStyle(e).width);const n=t/o*100;e.style.width=`${n}%`};
/**
 * Detect Node env
 *
 * @returns {boolean}
 */const be=()=>typeof window==="undefined"||typeof document==="undefined";const ve=`\n <div aria-labelledby="${u.title}" aria-describedby="${u["html-container"]}" class="${u.popup}" tabindex="-1">\n   <button type="button" class="${u.close}"></button>\n   <ul class="${u["progress-steps"]}"></ul>\n   <div class="${u.icon}"></div>\n   <img class="${u.image}" />\n   <h2 class="${u.title}" id="${u.title}"></h2>\n   <div class="${u["html-container"]}" id="${u["html-container"]}"></div>\n   <input class="${u.input}" id="${u.input}" />\n   <input type="file" class="${u.file}" />\n   <div class="${u.range}">\n     <input type="range" />\n     <output></output>\n   </div>\n   <select class="${u.select}" id="${u.select}"></select>\n   <div class="${u.radio}"></div>\n   <label class="${u.checkbox}">\n     <input type="checkbox" id="${u.checkbox}" />\n     <span class="${u.label}"></span>\n   </label>\n   <textarea class="${u.textarea}" id="${u.textarea}"></textarea>\n   <div class="${u["validation-message"]}" id="${u["validation-message"]}"></div>\n   <div class="${u.actions}">\n     <div class="${u.loader}"></div>\n     <button type="button" class="${u.confirm}"></button>\n     <button type="button" class="${u.deny}"></button>\n     <button type="button" class="${u.cancel}"></button>\n   </div>\n   <div class="${u.footer}"></div>\n   <div class="${u["timer-progress-bar-container"]}">\n     <div class="${u["timer-progress-bar"]}"></div>\n   </div>\n </div>\n`.replace(/(^|\n)\s*/g,"");
/**
 * @returns {boolean}
 */const ye=()=>{const e=E();if(!e)return false;e.remove();se([document.documentElement,document.body],[u["no-backdrop"],u["toast-shown"],u["has-column"]]);return true};const ke=()=>{r.currentInstance.resetValidationMessage()};const xe=()=>{const e=L();const t=ae(e,u.input);const o=ae(e,u.file);
/** @type {HTMLInputElement} */const n=e.querySelector(`.${u.range} input`);
/** @type {HTMLOutputElement} */const s=e.querySelector(`.${u.range} output`);const a=ae(e,u.select);
/** @type {HTMLInputElement} */const r=e.querySelector(`.${u.checkbox} input`);const i=ae(e,u.textarea);t.oninput=ke;o.onchange=ke;a.onchange=ke;r.onchange=ke;i.oninput=ke;n.oninput=()=>{ke();s.value=n.value};n.onchange=()=>{ke();s.value=n.value}};
/**
 * @param {string | HTMLElement} target
 * @returns {HTMLElement}
 */const Ce=e=>typeof e==="string"?document.querySelector(e):e
/**
 * @param {SweetAlertOptions} params
 */;const Ae=e=>{const t=L();t.setAttribute("role",e.toast?"alert":"dialog");t.setAttribute("aria-live",e.toast?"polite":"assertive");e.toast||t.setAttribute("aria-modal","true")};
/**
 * @param {HTMLElement} targetElement
 */const Ee=e=>{window.getComputedStyle(e).direction==="rtl"&&ne(E(),u.rtl)};
/**
 * Add modal + backdrop
 *
 * @param {SweetAlertOptions} params
 */const $e=e=>{const t=ye();if(be()){f("SweetAlert2 requires document to initialize");return}const o=document.createElement("div");o.className=u.container;t&&ne(o,u["no-transition"]);X(o,ve);o.dataset.swal2Theme=e.theme;const n=Ce(e.target);n.appendChild(o);Ae(e);Ee(n);xe()};
/**
 * @param {HTMLElement | object | string} param
 * @param {HTMLElement} target
 */const Be=(e,t)=>{e instanceof HTMLElement?t.appendChild(e):typeof e==="object"?Le(e,t):e&&X(t,e)};
/**
 * @param {any} param
 * @param {HTMLElement} target
 */const Le=(e,t)=>{e.jquery?Pe(t,e):X(t,e.toString())};
/**
 * @param {HTMLElement} target
 * @param {any} elem
 */const Pe=(e,t)=>{e.textContent="";if(0 in t)for(let o=0;o in t;o++)e.appendChild(t[o].cloneNode(true));else e.appendChild(t.cloneNode(true))};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Se=(e,t)=>{const o=N();const n=V();if(o&&n){t.showConfirmButton||t.showDenyButton||t.showCancelButton?ie(o):le(o);Q(o,t,"actions");Te(o,n,t);X(n,t.loaderHtml||"");Q(n,t,"loader")}};
/**
 * @param {HTMLElement} actions
 * @param {HTMLElement} loader
 * @param {SweetAlertOptions} params
 */function Te(e,t,o){const n=H();const s=q();const a=I();if(n&&s&&a){je(n,"confirm",o);je(s,"deny",o);je(a,"cancel",o);Oe(n,s,a,o);if(o.reverseButtons)if(o.toast){e.insertBefore(a,n);e.insertBefore(s,n)}else{e.insertBefore(a,t);e.insertBefore(s,t);e.insertBefore(n,t)}}}
/**
 * @param {HTMLElement} confirmButton
 * @param {HTMLElement} denyButton
 * @param {HTMLElement} cancelButton
 * @param {SweetAlertOptions} params
 */function Oe(e,t,o,n){if(n.buttonsStyling){ne([e,t,o],u.styled);if(n.confirmButtonColor){e.style.backgroundColor=n.confirmButtonColor;ne(e,u["default-outline"])}if(n.denyButtonColor){t.style.backgroundColor=n.denyButtonColor;ne(t,u["default-outline"])}if(n.cancelButtonColor){o.style.backgroundColor=n.cancelButtonColor;ne(o,u["default-outline"])}}else se([e,t,o],u.styled)}
/**
 * @param {HTMLElement} button
 * @param {'confirm' | 'deny' | 'cancel'} buttonType
 * @param {SweetAlertOptions} params
 */function je(e,t,o){const n=/** @type {'Confirm' | 'Deny' | 'Cancel'} */h(t);ue(e,o[`show${n}Button`],"inline-block");X(e,o[`${t}ButtonText`]||"");e.setAttribute("aria-label",o[`${t}ButtonAriaLabel`]||"");e.className=u[t];Q(e,o,`${t}Button`)}
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Me=(e,t)=>{const o=R();if(o){X(o,t.closeButtonHtml||"");Q(o,t,"closeButton");ue(o,t.showCloseButton);o.setAttribute("aria-label",t.closeButtonAriaLabel||"")}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const ze=(e,t)=>{const o=E();if(o){He(o,t.backdrop);Ie(o,t.position);qe(o,t.grow);Q(o,t,"container")}};
/**
 * @param {HTMLElement} container
 * @param {SweetAlertOptions['backdrop']} backdrop
 */function He(e,t){typeof t==="string"?e.style.background=t:t||ne([document.documentElement,document.body],u["no-backdrop"])}
/**
 * @param {HTMLElement} container
 * @param {SweetAlertOptions['position']} position
 */function Ie(e,t){if(t)if(t in u)ne(e,u[t]);else{g('The "position" parameter is not valid, defaulting to "center"');ne(e,u.center)}}
/**
 * @param {HTMLElement} container
 * @param {SweetAlertOptions['grow']} grow
 */function qe(e,t){t&&ne(e,u[`grow-${t}`])}var De={innerParams:new WeakMap,domCache:new WeakMap};
/** @type {InputClass[]} */const Ve=["input","file","range","select","radio","checkbox","textarea"];
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Ne=(e,t)=>{const o=L();if(!o)return;const n=De.innerParams.get(e);const s=!n||t.input!==n.input;Ve.forEach((e=>{const n=ae(o,u[e]);if(n){Re(e,t.inputAttributes);n.className=u[e];s&&le(n)}}));if(t.input){s&&_e(t);Ue(t)}};
/**
 * @param {SweetAlertOptions} params
 */const _e=e=>{if(!e.input)return;if(!Xe[e.input]){f(`Unexpected type of input! Expected ${Object.keys(Xe).join(" | ")}, got "${e.input}"`);return}const t=Ze(e.input);if(!t)return;const o=Xe[e.input](t,e);ie(t);e.inputAutoFocus&&setTimeout((()=>{te(o)}))};
/**
 * @param {HTMLInputElement} input
 */const Fe=e=>{for(let t=0;t<e.attributes.length;t++){const o=e.attributes[t].name;["id","type","value","style"].includes(o)||e.removeAttribute(o)}};
/**
 * @param {InputClass} inputClass
 * @param {SweetAlertOptions['inputAttributes']} inputAttributes
 */const Re=(e,t)=>{const o=L();if(!o)return;const n=ee(o,e);if(n){Fe(n);for(const e in t)n.setAttribute(e,t[e])}};
/**
 * @param {SweetAlertOptions} params
 */const Ue=e=>{if(!e.input)return;const t=Ze(e.input);t&&Q(t,e,"input")};
/**
 * @param {HTMLInputElement | HTMLTextAreaElement} input
 * @param {SweetAlertOptions} params
 */const Ye=(e,t)=>{!e.placeholder&&t.inputPlaceholder&&(e.placeholder=t.inputPlaceholder)};
/**
 * @param {Input} input
 * @param {Input} prependTo
 * @param {SweetAlertOptions} params
 */const We=(e,t,o)=>{if(o.inputLabel){const n=document.createElement("label");const s=u["input-label"];n.setAttribute("for",e.id);n.className=s;typeof o.customClass==="object"&&ne(n,o.customClass.inputLabel);n.innerText=o.inputLabel;t.insertAdjacentElement("beforebegin",n)}};
/**
 * @param {SweetAlertInput} inputType
 * @returns {HTMLElement | undefined}
 */const Ze=e=>{const t=L();if(t)return ae(t,u[/** @type {SwalClass} */e]||u.input)};
/**
 * @param {HTMLInputElement | HTMLOutputElement | HTMLTextAreaElement} input
 * @param {SweetAlertOptions['inputValue']} inputValue
 */const Ke=(e,t)=>{["string","number"].includes(typeof t)?e.value=`${t}`:A(t)||g(`Unexpected type of inputValue! Expected "string", "number" or "Promise", got "${typeof t}"`)};
/** @type {Record<SweetAlertInput, (input: Input | HTMLElement, params: SweetAlertOptions) => Input>} */const Xe={};
/**
 * @param {HTMLInputElement} input
 * @param {SweetAlertOptions} params
 * @returns {HTMLInputElement}
 */Xe.text=Xe.email=Xe.password=Xe.number=Xe.tel=Xe.url=Xe.search=Xe.date=Xe["datetime-local"]=Xe.time=Xe.week=Xe.month=/** @type {(input: Input | HTMLElement, params: SweetAlertOptions) => Input} */
(e,t)=>{Ke(e,t.inputValue);We(e,e,t);Ye(e,t);e.type=t.input;return e};
/**
 * @param {HTMLInputElement} input
 * @param {SweetAlertOptions} params
 * @returns {HTMLInputElement}
 */Xe.file=(e,t)=>{We(e,e,t);Ye(e,t);return e};
/**
 * @param {HTMLInputElement} range
 * @param {SweetAlertOptions} params
 * @returns {HTMLInputElement}
 */Xe.range=(e,t)=>{const o=e.querySelector("input");const n=e.querySelector("output");Ke(o,t.inputValue);o.type=t.input;Ke(n,t.inputValue);We(o,e,t);return e};
/**
 * @param {HTMLSelectElement} select
 * @param {SweetAlertOptions} params
 * @returns {HTMLSelectElement}
 */Xe.select=(e,t)=>{e.textContent="";if(t.inputPlaceholder){const o=document.createElement("option");X(o,t.inputPlaceholder);o.value="";o.disabled=true;o.selected=true;e.appendChild(o)}We(e,e,t);return e};
/**
 * @param {HTMLInputElement} radio
 * @returns {HTMLInputElement}
 */Xe.radio=e=>{e.textContent="";return e};
/**
 * @param {HTMLLabelElement} checkboxContainer
 * @param {SweetAlertOptions} params
 * @returns {HTMLInputElement}
 */Xe.checkbox=(e,t)=>{const o=ee(L(),"checkbox");o.value="1";o.checked=Boolean(t.inputValue);const n=e.querySelector("span");X(n,t.inputPlaceholder||t.inputLabel);return o};
/**
 * @param {HTMLTextAreaElement} textarea
 * @param {SweetAlertOptions} params
 * @returns {HTMLTextAreaElement}
 */Xe.textarea=(e,t)=>{Ke(e,t.inputValue);Ye(e,t);We(e,e,t);
/**
   * @param {HTMLElement} el
   * @returns {number}
   */const o=e=>parseInt(window.getComputedStyle(e).marginLeft)+parseInt(window.getComputedStyle(e).marginRight);setTimeout((()=>{if("MutationObserver"in window){const n=parseInt(window.getComputedStyle(L()).width);const s=()=>{if(!document.body.contains(e))return;const s=e.offsetWidth+o(e);s>n?L().style.width=`${s}px`:re(L(),"width",t.width)};new MutationObserver(s).observe(e,{attributes:true,attributeFilter:["style"]})}}));return e};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Je=(e,t)=>{const o=O();if(o){ce(o);Q(o,t,"htmlContainer");if(t.html){Be(t.html,o);ie(o,"block")}else if(t.text){o.textContent=t.text;ie(o,"block")}else le(o);Ne(e,t)}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Ge=(e,t)=>{const o=_();if(o){ce(o);ue(o,t.footer,"block");t.footer&&Be(t.footer,o);Q(o,t,"footer")}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Qe=(e,t)=>{const o=De.innerParams.get(e);const n=P();if(!n)return;if(o&&t.icon===o.icon){st(n,t);et(n,t);return}if(!t.icon&&!t.iconHtml){le(n);return}if(t.icon&&Object.keys(m).indexOf(t.icon)===-1){f(`Unknown icon! Expected "success", "error", "warning", "info" or "question", got "${t.icon}"`);le(n);return}ie(n);st(n,t);et(n,t);ne(n,t.showClass&&t.showClass.icon);const s=window.matchMedia("(prefers-color-scheme: dark)");s.addEventListener("change",tt)};
/**
 * @param {HTMLElement} icon
 * @param {SweetAlertOptions} params
 */const et=(e,t)=>{for(const[o,n]of Object.entries(m))t.icon!==o&&se(e,n);ne(e,t.icon&&m[t.icon]);at(e,t);tt();Q(e,t,"icon")};const tt=()=>{const e=L();if(!e)return;const t=window.getComputedStyle(e).getPropertyValue("background-color");
/** @type {NodeListOf<HTMLElement>} */const o=e.querySelectorAll("[class^=swal2-success-circular-line], .swal2-success-fix");for(let e=0;e<o.length;e++)o[e].style.backgroundColor=t};const ot='\n  <div class="swal2-success-circular-line-left"></div>\n  <span class="swal2-success-line-tip"></span> <span class="swal2-success-line-long"></span>\n  <div class="swal2-success-ring"></div> <div class="swal2-success-fix"></div>\n  <div class="swal2-success-circular-line-right"></div>\n';const nt='\n  <span class="swal2-x-mark">\n    <span class="swal2-x-mark-line-left"></span>\n    <span class="swal2-x-mark-line-right"></span>\n  </span>\n';
/**
 * @param {HTMLElement} icon
 * @param {SweetAlertOptions} params
 */const st=(e,t)=>{if(!t.icon&&!t.iconHtml)return;let o=e.innerHTML;let n="";if(t.iconHtml)n=rt(t.iconHtml);else if(t.icon==="success"){n=ot;o=o.replace(/ style=".*?"/g,"")}else if(t.icon==="error")n=nt;else if(t.icon){const e={question:"?",warning:"!",info:"i"};n=rt(e[t.icon])}o.trim()!==n.trim()&&X(e,n)};
/**
 * @param {HTMLElement} icon
 * @param {SweetAlertOptions} params
 */const at=(e,t)=>{if(t.iconColor){e.style.color=t.iconColor;e.style.borderColor=t.iconColor;for(const o of[".swal2-success-line-tip",".swal2-success-line-long",".swal2-x-mark-line-left",".swal2-x-mark-line-right"])de(e,o,"background-color",t.iconColor);de(e,".swal2-success-ring","border-color",t.iconColor)}};
/**
 * @param {string} content
 * @returns {string}
 */const rt=e=>`<div class="${u["icon-content"]}">${e}</div>`
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */;const it=(e,t)=>{const o=j();if(o)if(t.imageUrl){ie(o,"");o.setAttribute("src",t.imageUrl);o.setAttribute("alt",t.imageAlt||"");re(o,"width",t.imageWidth);re(o,"height",t.imageHeight);o.className=u.image;Q(o,t,"image")}else le(o)};let lt=false;let ct=0;let dt=0;let ut=0;let wt=0;
/**
 * @param {HTMLElement} popup
 */const mt=e=>{e.addEventListener("mousedown",ht);document.body.addEventListener("mousemove",gt);e.addEventListener("mouseup",ft);e.addEventListener("touchstart",ht);document.body.addEventListener("touchmove",gt);e.addEventListener("touchend",ft)};
/**
 * @param {HTMLElement} popup
 */const pt=e=>{e.removeEventListener("mousedown",ht);document.body.removeEventListener("mousemove",gt);e.removeEventListener("mouseup",ft);e.removeEventListener("touchstart",ht);document.body.removeEventListener("touchmove",gt);e.removeEventListener("touchend",ft)};
/**
 * @param {MouseEvent | TouchEvent} event
 */const ht=e=>{const t=L();if(e.target===t||P().contains(/** @type {HTMLElement} */e.target)){lt=true;const o=bt(e);ct=o.clientX;dt=o.clientY;ut=parseInt(t.style.insetInlineStart)||0;wt=parseInt(t.style.insetBlockStart)||0;ne(t,"swal2-dragging")}};
/**
 * @param {MouseEvent | TouchEvent} event
 */const gt=e=>{const t=L();if(lt){let{clientX:o,clientY:n}=bt(e);t.style.insetInlineStart=`${ut+(o-ct)}px`;t.style.insetBlockStart=`${wt+(n-dt)}px`}};const ft=()=>{const e=L();lt=false;se(e,"swal2-dragging")};
/**
 * @param {MouseEvent | TouchEvent} event
 * @returns {{ clientX: number, clientY: number }}
 */const bt=e=>{let t=0,o=0;if(e.type.startsWith("mouse")){t=/** @type {MouseEvent} */e.clientX;o=/** @type {MouseEvent} */e.clientY}else if(e.type.startsWith("touch")){t=/** @type {TouchEvent} */e.touches[0].clientX;o=/** @type {TouchEvent} */e.touches[0].clientY}return{clientX:t,clientY:o}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const vt=(e,t)=>{const o=E();const n=L();if(o&&n){if(t.toast){re(o,"width",t.width);n.style.width="100%";const e=V();e&&n.insertBefore(e,P())}else re(n,"width",t.width);re(n,"padding",t.padding);t.color&&(n.style.color=t.color);t.background&&(n.style.background=t.background);le(z());yt(n,t);if(t.draggable&&!t.toast){ne(n,u.draggable);mt(n)}else{se(n,u.draggable);pt(n)}}};
/**
 * @param {HTMLElement} popup
 * @param {SweetAlertOptions} params
 */const yt=(e,t)=>{const o=t.showClass||{};e.className=`${u.popup} ${we(e)?o.popup:""}`;if(t.toast){ne([document.documentElement,document.body],u["toast-shown"]);ne(e,u.toast)}else ne(e,u.modal);Q(e,t,"popup");typeof t.customClass==="string"&&ne(e,t.customClass);t.icon&&ne(e,u[`icon-${t.icon}`])};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const kt=(e,t)=>{const o=M();if(!o)return;const{progressSteps:n,currentProgressStep:s}=t;if(n&&n.length!==0&&s!==void 0){ie(o);o.textContent="";s>=n.length&&g("Invalid currentProgressStep parameter, it should be less than progressSteps.length (currentProgressStep like JS arrays starts from 0)");n.forEach(((e,a)=>{const r=xt(e);o.appendChild(r);a===s&&ne(r,u["active-progress-step"]);if(a!==n.length-1){const e=Ct(t);o.appendChild(e)}}))}else le(o)};
/**
 * @param {string} step
 * @returns {HTMLLIElement}
 */const xt=e=>{const t=document.createElement("li");ne(t,u["progress-step"]);X(t,e);return t};
/**
 * @param {SweetAlertOptions} params
 * @returns {HTMLLIElement}
 */const Ct=e=>{const t=document.createElement("li");ne(t,u["progress-step-line"]);e.progressStepsDistance&&re(t,"width",e.progressStepsDistance);return t};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const At=(e,t)=>{const o=T();if(o){ce(o);ue(o,t.title||t.titleText,"block");t.title&&Be(t.title,o);t.titleText&&(o.innerText=t.titleText);Q(o,t,"title")}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const Et=(e,t)=>{vt(e,t);ze(e,t);kt(e,t);Qe(e,t);it(e,t);At(e,t);Me(e,t);Je(e,t);Se(e,t);Ge(e,t);const o=L();typeof t.didRender==="function"&&o&&t.didRender(o);r.eventEmitter.emit("didRender",o)};const $t=()=>we(L());const Bt=()=>{var e;return(e=H())===null||e===void 0?void 0:e.click()};const Lt=()=>{var e;return(e=q())===null||e===void 0?void 0:e.click()};const Pt=()=>{var e;return(e=I())===null||e===void 0?void 0:e.click()};
/** @typedef {'cancel' | 'backdrop' | 'close' | 'esc' | 'timer'} DismissReason */
/** @type {Record<DismissReason, DismissReason>} */const St=Object.freeze({cancel:"cancel",backdrop:"backdrop",close:"close",esc:"esc",timer:"timer"});
/**
 * @param {GlobalState} globalState
 */const Tt=e=>{if(e.keydownTarget&&e.keydownHandlerAdded){e.keydownTarget.removeEventListener("keydown",e.keydownHandler,{capture:e.keydownListenerCapture});e.keydownHandlerAdded=false}};
/**
 * @param {GlobalState} globalState
 * @param {SweetAlertOptions} innerParams
 * @param {*} dismissWith
 */const Ot=(e,t,o)=>{Tt(e);if(!t.toast){e.keydownHandler=e=>Ht(t,e,o);e.keydownTarget=t.keydownListenerCapture?window:L();e.keydownListenerCapture=t.keydownListenerCapture;e.keydownTarget.addEventListener("keydown",e.keydownHandler,{capture:e.keydownListenerCapture});e.keydownHandlerAdded=true}};
/**
 * @param {number} index
 * @param {number} increment
 */const jt=(e,t)=>{var o;const n=Y();if(n.length){e+=t;e===n.length?e=0:e===-1&&(e=n.length-1);n[e].focus()}else(o=L())===null||o===void 0||o.focus()};const Mt=["ArrowRight","ArrowDown"];const zt=["ArrowLeft","ArrowUp"];
/**
 * @param {SweetAlertOptions} innerParams
 * @param {KeyboardEvent} event
 * @param {Function} dismissWith
 */const Ht=(e,t,o)=>{if(e&&!t.isComposing&&t.keyCode!==229){e.stopKeydownPropagation&&t.stopPropagation();t.key==="Enter"?It(t,e):t.key==="Tab"?qt(t):[...Mt,...zt].includes(t.key)?Dt(t.key):t.key==="Escape"&&Vt(t,e,o)}};
/**
 * @param {KeyboardEvent} event
 * @param {SweetAlertOptions} innerParams
 */const It=(e,t)=>{if(!k(t.allowEnterKey))return;const o=ee(L(),t.input);if(e.target&&o&&e.target instanceof HTMLElement&&e.target.outerHTML===o.outerHTML){if(["textarea","file"].includes(t.input))return;Bt();e.preventDefault()}};
/**
 * @param {KeyboardEvent} event
 */const qt=e=>{const t=e.target;const o=Y();let n=-1;for(let e=0;e<o.length;e++)if(t===o[e]){n=e;break}e.shiftKey?jt(n,-1):jt(n,1);e.stopPropagation();e.preventDefault()};
/**
 * @param {string} key
 */const Dt=e=>{const t=N();const o=H();const n=q();const s=I();if(!t||!o||!n||!s)return;
/** @type HTMLElement[] */const a=[o,n,s];if(document.activeElement instanceof HTMLElement&&!a.includes(document.activeElement))return;const r=Mt.includes(e)?"nextElementSibling":"previousElementSibling";let i=document.activeElement;if(i){for(let e=0;e<t.children.length;e++){i=i[r];if(!i)return;if(i instanceof HTMLButtonElement&&we(i))break}i instanceof HTMLButtonElement&&i.focus()}};
/**
 * @param {KeyboardEvent} event
 * @param {SweetAlertOptions} innerParams
 * @param {Function} dismissWith
 */const Vt=(e,t,o)=>{if(k(t.allowEscapeKey)){e.preventDefault();o(St.esc)}};var Nt={swalPromiseResolve:new WeakMap,swalPromiseReject:new WeakMap};const _t=()=>{const e=E();const t=Array.from(document.body.children);t.forEach((t=>{if(!t.contains(e)){t.hasAttribute("aria-hidden")&&t.setAttribute("data-previous-aria-hidden",t.getAttribute("aria-hidden")||"");t.setAttribute("aria-hidden","true")}}))};const Ft=()=>{const e=Array.from(document.body.children);e.forEach((e=>{if(e.hasAttribute("data-previous-aria-hidden")){e.setAttribute("aria-hidden",e.getAttribute("data-previous-aria-hidden")||"");e.removeAttribute("data-previous-aria-hidden")}else e.removeAttribute("aria-hidden")}))};const Rt=typeof window!=="undefined"&&!!window.GestureEvent;const Ut=()=>{if(Rt&&!J(document.body,u.iosfix)){const e=document.body.scrollTop;document.body.style.top=e*-1+"px";ne(document.body,u.iosfix);Yt()}};const Yt=()=>{const e=E();if(!e)return;
/** @type {boolean} */let t;
/**
   * @param {TouchEvent} event
   */e.ontouchstart=e=>{t=Wt(e)};
/**
   * @param {TouchEvent} event
   */e.ontouchmove=e=>{if(t){e.preventDefault();e.stopPropagation()}}};
/**
 * @param {TouchEvent} event
 * @returns {boolean}
 */const Wt=e=>{const t=e.target;const o=E();const n=O();return!(!o||!n)&&(!Zt(e)&&!Kt(e)&&(t===o||!pe(o)&&t instanceof HTMLElement&&t.tagName!=="INPUT"&&t.tagName!=="TEXTAREA"&&(!pe(n)||!n.contains(t))))};
/**
 * https://github.com/sweetalert2/sweetalert2/issues/1786
 *
 * @param {*} event
 * @returns {boolean}
 */const Zt=e=>e.touches&&e.touches.length&&e.touches[0].touchType==="stylus";
/**
 * https://github.com/sweetalert2/sweetalert2/issues/1891
 *
 * @param {TouchEvent} event
 * @returns {boolean}
 */const Kt=e=>e.touches&&e.touches.length>1;const Xt=()=>{if(J(document.body,u.iosfix)){const e=parseInt(document.body.style.top,10);se(document.body,u.iosfix);document.body.style.top="";document.body.scrollTop=e*-1}};
/**
 * Measure scrollbar width for padding body during modal show/hide
 * https://github.com/twbs/bootstrap/blob/master/js/src/modal.js
 *
 * @returns {number}
 */const Jt=()=>{const e=document.createElement("div");e.className=u["scrollbar-measure"];document.body.appendChild(e);const t=e.getBoundingClientRect().width-e.clientWidth;document.body.removeChild(e);return t};
/**
 * Remember state in cases where opening and handling a modal will fiddle with it.
 * @type {number | null}
 */let Gt=null;
/**
 * @param {string} initialBodyOverflow
 */const Qt=e=>{if(Gt===null&&(document.body.scrollHeight>window.innerHeight||e==="scroll")){Gt=parseInt(window.getComputedStyle(document.body).getPropertyValue("padding-right"));document.body.style.paddingRight=`${Gt+Jt()}px`}};const eo=()=>{if(Gt!==null){document.body.style.paddingRight=`${Gt}px`;Gt=null}};
/**
 * @param {SweetAlert} instance
 * @param {HTMLElement} container
 * @param {boolean} returnFocus
 * @param {Function} didClose
 */function to(e,t,o,n){if(Z())uo(e,n);else{l(o).then((()=>uo(e,n)));Tt(r)}if(Rt){t.setAttribute("style","display:none !important");t.removeAttribute("class");t.innerHTML=""}else t.remove();if(W()){eo();Xt();Ft()}oo()}function oo(){se([document.documentElement,document.body],[u.shown,u["height-auto"],u["no-backdrop"],u["toast-shown"]])}
/**
 * Instance method to close sweetAlert
 *
 * @param {any} resolveValue
 */function no(e){e=io(e);const t=Nt.swalPromiseResolve.get(this);const o=so(this);if(this.isAwaitingPromise){if(!e.isDismissed){ro(this);t(e)}}else o&&t(e)}const so=e=>{const t=L();if(!t)return false;const o=De.innerParams.get(e);if(!o||J(t,o.hideClass.popup))return false;se(t,o.showClass.popup);ne(t,o.hideClass.popup);const n=E();se(n,o.showClass.backdrop);ne(n,o.hideClass.backdrop);lo(e,t,o);return true};
/**
 * @param {any} error
 */function ao(e){const t=Nt.swalPromiseReject.get(this);ro(this);t&&t(e)}
/**
 * @param {SweetAlert} instance
 */const ro=e=>{if(e.isAwaitingPromise){delete e.isAwaitingPromise;De.innerParams.get(e)||e._destroy()}};
/**
 * @param {any} resolveValue
 * @returns {SweetAlertResult}
 */const io=e=>typeof e==="undefined"?{isConfirmed:false,isDenied:false,isDismissed:true}:Object.assign({isConfirmed:false,isDenied:false,isDismissed:false},e);
/**
 * @param {SweetAlert} instance
 * @param {HTMLElement} popup
 * @param {SweetAlertOptions} innerParams
 */const lo=(e,t,o)=>{var n;const s=E();const a=he(t);typeof o.willClose==="function"&&o.willClose(t);(n=r.eventEmitter)===null||n===void 0||n.emit("willClose",t);a?co(e,t,s,o.returnFocus,o.didClose):to(e,s,o.returnFocus,o.didClose)};
/**
 * @param {SweetAlert} instance
 * @param {HTMLElement} popup
 * @param {HTMLElement} container
 * @param {boolean} returnFocus
 * @param {Function} didClose
 */const co=(e,t,o,n,s)=>{r.swalCloseEventFinishedCallback=to.bind(null,e,o,n,s);
/**
   * @param {AnimationEvent | TransitionEvent} e
   */const a=function(e){if(e.target===t){var o;(o=r.swalCloseEventFinishedCallback)===null||o===void 0||o.call(r);delete r.swalCloseEventFinishedCallback;t.removeEventListener("animationend",a);t.removeEventListener("transitionend",a)}};t.addEventListener("animationend",a);t.addEventListener("transitionend",a)};
/**
 * @param {SweetAlert} instance
 * @param {Function} didClose
 */const uo=(e,t)=>{setTimeout((()=>{var o;typeof t==="function"&&t.bind(e.params)();(o=r.eventEmitter)===null||o===void 0||o.emit("didClose");e._destroy&&e._destroy()}))};
/**
 * Shows loader (spinner), this is useful with AJAX requests.
 * By default the loader be shown instead of the "Confirm" button.
 *
 * @param {HTMLButtonElement | null} [buttonToReplace]
 */const wo=e=>{let t=L();t||new ms;t=L();if(!t)return;const o=V();Z()?le(P()):mo(t,e);ie(o);t.setAttribute("data-loading","true");t.setAttribute("aria-busy","true");t.focus()};
/**
 * @param {HTMLElement} popup
 * @param {HTMLButtonElement | null} [buttonToReplace]
 */const mo=(e,t)=>{const o=N();const n=V();if(o&&n){!t&&we(H())&&(t=H());ie(o);if(t){le(t);n.setAttribute("data-button-to-replace",t.className);o.insertBefore(n,t)}ne([e,o],u.loading)}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const po=(e,t)=>{if(t.input==="select"||t.input==="radio")vo(e,t);else if(["text","email","number","tel","textarea"].some((e=>e===t.input))&&(x(t.inputValue)||A(t.inputValue))){wo(H());yo(e,t)}};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} innerParams
 * @returns {SweetAlertInputValue}
 */const ho=(e,t)=>{const o=e.getInput();if(!o)return null;switch(t.input){case"checkbox":return go(o);case"radio":return fo(o);case"file":return bo(o);default:return t.inputAutoTrim?o.value.trim():o.value}};
/**
 * @param {HTMLInputElement} input
 * @returns {number}
 */const go=e=>e.checked?1:0
/**
 * @param {HTMLInputElement} input
 * @returns {string | null}
 */;const fo=e=>e.checked?e.value:null
/**
 * @param {HTMLInputElement} input
 * @returns {FileList | File | null}
 */;const bo=e=>e.files&&e.files.length?e.getAttribute("multiple")!==null?e.files:e.files[0]:null
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */;const vo=(e,t)=>{const o=L();if(!o)return;
/**
   * @param {Record<string, any>} inputOptions
   */const n=e=>{t.input==="select"?ko(o,Co(e),t):t.input==="radio"&&xo(o,Co(e),t)};if(x(t.inputOptions)||A(t.inputOptions)){wo(H());C(t.inputOptions).then((t=>{e.hideLoading();n(t)}))}else typeof t.inputOptions==="object"?n(t.inputOptions):f("Unexpected type of inputOptions! Expected object, Map or Promise, got "+typeof t.inputOptions)};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertOptions} params
 */const yo=(e,t)=>{const o=e.getInput();if(o){le(o);C(t.inputValue).then((n=>{o.value=t.input==="number"?`${parseFloat(n)||0}`:`${n}`;ie(o);o.focus();e.hideLoading()})).catch((t=>{f(`Error in inputValue promise: ${t}`);o.value="";ie(o);o.focus();e.hideLoading()}))}};
/**
 * @param {HTMLElement} popup
 * @param {InputOptionFlattened[]} inputOptions
 * @param {SweetAlertOptions} params
 */function ko(e,t,o){const n=ae(e,u.select);if(!n)return;
/**
   * @param {HTMLElement} parent
   * @param {string} optionLabel
   * @param {string} optionValue
   */const s=(e,t,n)=>{const s=document.createElement("option");s.value=n;X(s,t);s.selected=Ao(n,o.inputValue);e.appendChild(s)};t.forEach((e=>{const t=e[0];const o=e[1];if(Array.isArray(o)){const e=document.createElement("optgroup");e.label=t;e.disabled=false;n.appendChild(e);o.forEach((t=>s(e,t[1],t[0])))}else s(n,o,t)}));n.focus()}
/**
 * @param {HTMLElement} popup
 * @param {InputOptionFlattened[]} inputOptions
 * @param {SweetAlertOptions} params
 */function xo(e,t,o){const n=ae(e,u.radio);if(!n)return;t.forEach((e=>{const t=e[0];const s=e[1];const a=document.createElement("input");const r=document.createElement("label");a.type="radio";a.name=u.radio;a.value=t;Ao(t,o.inputValue)&&(a.checked=true);const i=document.createElement("span");X(i,s);i.className=u.label;r.appendChild(a);r.appendChild(i);n.appendChild(r)}));const s=n.querySelectorAll("input");s.length&&s[0].focus()}
/**
 * Converts `inputOptions` into an array of `[value, label]`s
 *
 * @param {Record<string, any>} inputOptions
 * @typedef {string[]} InputOptionFlattened
 * @returns {InputOptionFlattened[]}
 */const Co=e=>{
/** @type {InputOptionFlattened[]} */
const t=[];e instanceof Map?e.forEach(((e,o)=>{let n=e;typeof n==="object"&&(n=Co(n));t.push([o,n])})):Object.keys(e).forEach((o=>{let n=e[o];typeof n==="object"&&(n=Co(n));t.push([o,n])}));return t};
/**
 * @param {string} optionValue
 * @param {SweetAlertInputValue} inputValue
 * @returns {boolean}
 */const Ao=(e,t)=>!!t&&t.toString()===e.toString();
/**
 * @param {SweetAlert} instance
 */const Eo=e=>{const t=De.innerParams.get(e);e.disableButtons();t.input?Lo(e,"confirm"):jo(e,true)};
/**
 * @param {SweetAlert} instance
 */const $o=e=>{const t=De.innerParams.get(e);e.disableButtons();t.returnInputValueOnDeny?Lo(e,"deny"):So(e,false)};
/**
 * @param {SweetAlert} instance
 * @param {Function} dismissWith
 */const Bo=(e,t)=>{e.disableButtons();t(St.cancel)};
/**
 * @param {SweetAlert} instance
 * @param {'confirm' | 'deny'} type
 */const Lo=(e,t)=>{const o=De.innerParams.get(e);if(!o.input){f(`The "input" parameter is needed to be set when using returnInputValueOn${h(t)}`);return}const n=e.getInput();const s=ho(e,o);if(o.inputValidator)Po(e,s,t);else if(n&&!n.checkValidity()){e.enableButtons();e.showValidationMessage(o.validationMessage||n.validationMessage)}else t==="deny"?So(e,s):jo(e,s)};
/**
 * @param {SweetAlert} instance
 * @param {SweetAlertInputValue} inputValue
 * @param {'confirm' | 'deny'} type
 */const Po=(e,t,o)=>{const n=De.innerParams.get(e);e.disableInput();const s=Promise.resolve().then((()=>C(n.inputValidator(t,n.validationMessage))));s.then((n=>{e.enableButtons();e.enableInput();n?e.showValidationMessage(n):o==="deny"?So(e,t):jo(e,t)}))};
/**
 * @param {SweetAlert} instance
 * @param {any} value
 */const So=(e,t)=>{const o=De.innerParams.get(e||void 0);o.showLoaderOnDeny&&wo(q());if(o.preDeny){e.isAwaitingPromise=true;const n=Promise.resolve().then((()=>C(o.preDeny(t,o.validationMessage))));n.then((o=>{if(o===false){e.hideLoading();ro(e)}else e.close({isDenied:true,value:typeof o==="undefined"?t:o})})).catch((t=>Oo(e||void 0,t)))}else e.close({isDenied:true,value:t})};
/**
 * @param {SweetAlert} instance
 * @param {any} value
 */const To=(e,t)=>{e.close({isConfirmed:true,value:t})};
/**
 *
 * @param {SweetAlert} instance
 * @param {string} error
 */const Oo=(e,t)=>{e.rejectPromise(t)};
/**
 *
 * @param {SweetAlert} instance
 * @param {any} value
 */const jo=(e,t)=>{const o=De.innerParams.get(e||void 0);o.showLoaderOnConfirm&&wo();if(o.preConfirm){e.resetValidationMessage();e.isAwaitingPromise=true;const n=Promise.resolve().then((()=>C(o.preConfirm(t,o.validationMessage))));n.then((o=>{if(we(z())||o===false){e.hideLoading();ro(e)}else To(e,typeof o==="undefined"?t:o)})).catch((t=>Oo(e||void 0,t)))}else To(e,t)};function Mo(){const e=De.innerParams.get(this);if(!e)return;const t=De.domCache.get(this);le(t.loader);Z()?e.icon&&ie(P()):zo(t);se([t.popup,t.actions],u.loading);t.popup.removeAttribute("aria-busy");t.popup.removeAttribute("data-loading");t.confirmButton.disabled=false;t.denyButton.disabled=false;t.cancelButton.disabled=false}const zo=e=>{const t=e.popup.getElementsByClassName(e.loader.getAttribute("data-button-to-replace"));t.length?ie(t[0],"inline-block"):me()&&le(e.actions)};
/**
 * Gets the input DOM node, this method works with input parameter.
 *
 * @returns {HTMLInputElement | null}
 */function Ho(){const e=De.innerParams.get(this);const t=De.domCache.get(this);return t?ee(t.popup,e.input):null}
/**
 * @param {SweetAlert} instance
 * @param {string[]} buttons
 * @param {boolean} disabled
 */function Io(e,t,o){const n=De.domCache.get(e);t.forEach((e=>{n[e].disabled=o}))}
/**
 * @param {HTMLInputElement | null} input
 * @param {boolean} disabled
 */function qo(e,t){const o=L();if(o&&e)if(e.type==="radio"){
/** @type {NodeListOf<HTMLInputElement>} */
const e=o.querySelectorAll(`[name="${u.radio}"]`);for(let o=0;o<e.length;o++)e[o].disabled=t}else e.disabled=t}function Do(){Io(this,["confirmButton","denyButton","cancelButton"],false)}function Vo(){Io(this,["confirmButton","denyButton","cancelButton"],true)}function No(){qo(this.getInput(),false)}function _o(){qo(this.getInput(),true)}
/**
 * Show block with validation message
 *
 * @param {string} error
 * @this {SweetAlert}
 */function Fo(e){const t=De.domCache.get(this);const o=De.innerParams.get(this);X(t.validationMessage,e);t.validationMessage.className=u["validation-message"];o.customClass&&o.customClass.validationMessage&&ne(t.validationMessage,o.customClass.validationMessage);ie(t.validationMessage);const n=this.getInput();if(n){n.setAttribute("aria-invalid","true");n.setAttribute("aria-describedby",u["validation-message"]);te(n);ne(n,u.inputerror)}}function Ro(){const e=De.domCache.get(this);e.validationMessage&&le(e.validationMessage);const t=this.getInput();if(t){t.removeAttribute("aria-invalid");t.removeAttribute("aria-describedby");se(t,u.inputerror)}}const Uo={title:"",titleText:"",text:"",html:"",footer:"",icon:void 0,iconColor:void 0,iconHtml:void 0,template:void 0,toast:false,draggable:false,animation:true,theme:"light",showClass:{popup:"swal2-show",backdrop:"swal2-backdrop-show",icon:"swal2-icon-show"},hideClass:{popup:"swal2-hide",backdrop:"swal2-backdrop-hide",icon:"swal2-icon-hide"},customClass:{},target:"body",color:void 0,backdrop:true,heightAuto:true,allowOutsideClick:true,allowEscapeKey:true,allowEnterKey:true,stopKeydownPropagation:true,keydownListenerCapture:false,showConfirmButton:true,showDenyButton:false,showCancelButton:false,preConfirm:void 0,preDeny:void 0,confirmButtonText:"OK",confirmButtonAriaLabel:"",confirmButtonColor:void 0,denyButtonText:"No",denyButtonAriaLabel:"",denyButtonColor:void 0,cancelButtonText:"Cancel",cancelButtonAriaLabel:"",cancelButtonColor:void 0,buttonsStyling:true,reverseButtons:false,focusConfirm:true,focusDeny:false,focusCancel:false,returnFocus:true,showCloseButton:false,closeButtonHtml:"&times;",closeButtonAriaLabel:"Close this dialog",loaderHtml:"",showLoaderOnConfirm:false,showLoaderOnDeny:false,imageUrl:void 0,imageWidth:void 0,imageHeight:void 0,imageAlt:"",timer:void 0,timerProgressBar:false,width:void 0,padding:void 0,background:void 0,input:void 0,inputPlaceholder:"",inputLabel:"",inputValue:"",inputOptions:{},inputAutoFocus:true,inputAutoTrim:true,inputAttributes:{},inputValidator:void 0,returnInputValueOnDeny:false,validationMessage:void 0,grow:false,position:"center",progressSteps:[],currentProgressStep:void 0,progressStepsDistance:void 0,willOpen:void 0,didOpen:void 0,didRender:void 0,willClose:void 0,didClose:void 0,didDestroy:void 0,scrollbarPadding:true};const Yo=["allowEscapeKey","allowOutsideClick","background","buttonsStyling","cancelButtonAriaLabel","cancelButtonColor","cancelButtonText","closeButtonAriaLabel","closeButtonHtml","color","confirmButtonAriaLabel","confirmButtonColor","confirmButtonText","currentProgressStep","customClass","denyButtonAriaLabel","denyButtonColor","denyButtonText","didClose","didDestroy","draggable","footer","hideClass","html","icon","iconColor","iconHtml","imageAlt","imageHeight","imageUrl","imageWidth","preConfirm","preDeny","progressSteps","returnFocus","reverseButtons","showCancelButton","showCloseButton","showConfirmButton","showDenyButton","text","title","titleText","theme","willClose"];
/** @type {Record<string, string | undefined>} */const Wo={allowEnterKey:void 0};const Zo=["allowOutsideClick","allowEnterKey","backdrop","draggable","focusConfirm","focusDeny","focusCancel","returnFocus","heightAuto","keydownListenerCapture"];
/**
 * Is valid parameter
 *
 * @param {string} paramName
 * @returns {boolean}
 */const Ko=e=>Object.prototype.hasOwnProperty.call(Uo,e);
/**
 * Is valid parameter for Swal.update() method
 *
 * @param {string} paramName
 * @returns {boolean}
 */const Xo=e=>Yo.indexOf(e)!==-1;
/**
 * Is deprecated parameter
 *
 * @param {string} paramName
 * @returns {string | undefined}
 */const Jo=e=>Wo[e];
/**
 * @param {string} param
 */const Go=e=>{Ko(e)||g(`Unknown parameter "${e}"`)};
/**
 * @param {string} param
 */const Qo=e=>{Zo.includes(e)&&g(`The parameter "${e}" is incompatible with toasts`)};
/**
 * @param {string} param
 */const en=e=>{const t=Jo(e);t&&y(e,t)};
/**
 * Show relevant warnings for given params
 *
 * @param {SweetAlertOptions} params
 */const tn=e=>{e.backdrop===false&&e.allowOutsideClick&&g('"allowOutsideClick" parameter requires `backdrop` parameter to be set to `true`');e.theme&&!["light","dark","auto","borderless","embed-iframe"].includes(e.theme)&&g(`Invalid theme "${e.theme}". Expected "light", "dark", "auto", "borderless", or "embed-iframe"`);for(const t in e){Go(t);e.toast&&Qo(t);en(t)}};
/**
 * Updates popup parameters.
 *
 * @param {SweetAlertOptions} params
 */function on(e){const t=E();const o=L();const n=De.innerParams.get(this);if(!o||J(o,n.hideClass.popup)){g("You're trying to update the closed or closing popup, that won't work. Use the update() method in preConfirm parameter or show a new popup.");return}const s=nn(e);const a=Object.assign({},n,s);tn(a);t.dataset.swal2Theme=a.theme;Et(this,a);De.innerParams.set(this,a);Object.defineProperties(this,{params:{value:Object.assign({},this.params,e),writable:false,enumerable:true}})}
/**
 * @param {SweetAlertOptions} params
 * @returns {SweetAlertOptions}
 */const nn=e=>{const t={};Object.keys(e).forEach((o=>{Xo(o)?t[o]=e[o]:g(`Invalid parameter to update: ${o}`)}));return t};function sn(){const e=De.domCache.get(this);const t=De.innerParams.get(this);if(t){if(e.popup&&r.swalCloseEventFinishedCallback){r.swalCloseEventFinishedCallback();delete r.swalCloseEventFinishedCallback}typeof t.didDestroy==="function"&&t.didDestroy();r.eventEmitter.emit("didDestroy");an(this)}else rn(this)}
/**
 * @param {SweetAlert} instance
 */const an=e=>{rn(e);delete e.params;delete r.keydownHandler;delete r.keydownTarget;delete r.currentInstance};
/**
 * @param {SweetAlert} instance
 */const rn=e=>{if(e.isAwaitingPromise){ln(De,e);e.isAwaitingPromise=true}else{ln(Nt,e);ln(De,e);delete e.isAwaitingPromise;delete e.disableButtons;delete e.enableButtons;delete e.getInput;delete e.disableInput;delete e.enableInput;delete e.hideLoading;delete e.disableLoading;delete e.showValidationMessage;delete e.resetValidationMessage;delete e.close;delete e.closePopup;delete e.closeModal;delete e.closeToast;delete e.rejectPromise;delete e.update;delete e._destroy}};
/**
 * @param {object} obj
 * @param {SweetAlert} instance
 */const ln=(e,t)=>{for(const o in e)e[o].delete(t)};var cn=Object.freeze({__proto__:null,_destroy:sn,close:no,closeModal:no,closePopup:no,closeToast:no,disableButtons:Vo,disableInput:_o,disableLoading:Mo,enableButtons:Do,enableInput:No,getInput:Ho,handleAwaitingPromise:ro,hideLoading:Mo,rejectPromise:ao,resetValidationMessage:Ro,showValidationMessage:Fo,update:on});
/**
 * @param {SweetAlertOptions} innerParams
 * @param {DomCache} domCache
 * @param {Function} dismissWith
 */const dn=(e,t,o)=>{if(e.toast)un(e,t,o);else{pn(t);hn(t);gn(e,t,o)}};
/**
 * @param {SweetAlertOptions} innerParams
 * @param {DomCache} domCache
 * @param {Function} dismissWith
 */const un=(e,t,o)=>{t.popup.onclick=()=>{e&&(wn(e)||e.timer||e.input)||o(St.close)}};
/**
 * @param {SweetAlertOptions} innerParams
 * @returns {boolean}
 */const wn=e=>!!(e.showConfirmButton||e.showDenyButton||e.showCancelButton||e.showCloseButton);let mn=false;
/**
 * @param {DomCache} domCache
 */const pn=e=>{e.popup.onmousedown=()=>{e.container.onmouseup=function(t){e.container.onmouseup=()=>{};t.target===e.container&&(mn=true)}}};
/**
 * @param {DomCache} domCache
 */const hn=e=>{e.container.onmousedown=t=>{t.target===e.container&&t.preventDefault();e.popup.onmouseup=function(t){e.popup.onmouseup=()=>{};(t.target===e.popup||t.target instanceof HTMLElement&&e.popup.contains(t.target))&&(mn=true)}}};
/**
 * @param {SweetAlertOptions} innerParams
 * @param {DomCache} domCache
 * @param {Function} dismissWith
 */const gn=(e,t,o)=>{t.container.onclick=n=>{mn?mn=false:n.target===t.container&&k(e.allowOutsideClick)&&o(St.backdrop)}};const fn=e=>typeof e==="object"&&e.jquery;const bn=e=>e instanceof Element||fn(e);const vn=e=>{const t={};typeof e[0]!=="object"||bn(e[0])?["title","html","icon"].forEach(((o,n)=>{const s=e[n];typeof s==="string"||bn(s)?t[o]=s:s!==void 0&&f(`Unexpected type of ${o}! Expected "string" or "Element", got ${typeof s}`)})):Object.assign(t,e[0]);return t};
/**
 * Main method to create a new SweetAlert2 popup
 *
 * @param  {...SweetAlertOptions} args
 * @returns {Promise<SweetAlertResult>}
 */function yn(){for(var e=arguments.length,t=new Array(e),o=0;o<e;o++)t[o]=arguments[o];return new this(...t)}
/**
 * Returns an extended version of `Swal` containing `params` as defaults.
 * Useful for reusing Swal configuration.
 *
 * For example:
 *
 * Before:
 * const textPromptOptions = { input: 'text', showCancelButton: true }
 * const {value: firstName} = await Swal.fire({ ...textPromptOptions, title: 'What is your first name?' })
 * const {value: lastName} = await Swal.fire({ ...textPromptOptions, title: 'What is your last name?' })
 *
 * After:
 * const TextPrompt = Swal.mixin({ input: 'text', showCancelButton: true })
 * const {value: firstName} = await TextPrompt('What is your first name?')
 * const {value: lastName} = await TextPrompt('What is your last name?')
 *
 * @param {SweetAlertOptions} mixinParams
 * @returns {SweetAlert}
 */function kn(e){class MixinSwal extends(this){_main(t,o){return super._main(t,Object.assign({},e,o))}}return MixinSwal}
/**
 * If `timer` parameter is set, returns number of milliseconds of timer remained.
 * Otherwise, returns undefined.
 *
 * @returns {number | undefined}
 */const xn=()=>r.timeout&&r.timeout.getTimerLeft();
/**
 * Stop timer. Returns number of milliseconds of timer remained.
 * If `timer` parameter isn't set, returns undefined.
 *
 * @returns {number | undefined}
 */const Cn=()=>{if(r.timeout){fe();return r.timeout.stop()}};
/**
 * Resume timer. Returns number of milliseconds of timer remained.
 * If `timer` parameter isn't set, returns undefined.
 *
 * @returns {number | undefined}
 */const An=()=>{if(r.timeout){const e=r.timeout.start();ge(e);return e}};
/**
 * Resume timer. Returns number of milliseconds of timer remained.
 * If `timer` parameter isn't set, returns undefined.
 *
 * @returns {number | undefined}
 */const En=()=>{const e=r.timeout;return e&&(e.running?Cn():An())};
/**
 * Increase timer. Returns number of milliseconds of an updated timer.
 * If `timer` parameter isn't set, returns undefined.
 *
 * @param {number} ms
 * @returns {number | undefined}
 */const $n=e=>{if(r.timeout){const t=r.timeout.increase(e);ge(t,true);return t}};
/**
 * Check if timer is running. Returns true if timer is running
 * or false if timer is paused or stopped.
 * If `timer` parameter isn't set, returns undefined
 *
 * @returns {boolean}
 */const Bn=()=>!!(r.timeout&&r.timeout.isRunning());let Ln=false;const Pn={};
/**
 * @param {string} attr
 */function Sn(){let e=arguments.length>0&&arguments[0]!==void 0?arguments[0]:"data-swal-template";Pn[e]=this;if(!Ln){document.body.addEventListener("click",Tn);Ln=true}}const Tn=e=>{for(let t=e.target;t&&t!==document;t=t.parentNode)for(const e in Pn){const o=t.getAttribute(e);if(o){Pn[e].fire({template:o});return}}};class EventEmitter{constructor(){
/** @type {Events} */
this.events={}}
/**
   * @param {string} eventName
   * @returns {EventHandlers}
   */_getHandlersByEventName(e){typeof this.events[e]==="undefined"&&(this.events[e]=[]);return this.events[e]}
/**
   * @param {string} eventName
   * @param {EventHandler} eventHandler
   */on(e,t){const o=this._getHandlersByEventName(e);o.includes(t)||o.push(t)}
/**
   * @param {string} eventName
   * @param {EventHandler} eventHandler
   */once(e,t){var o=this;
/**
     * @param {Array} args
     */const n=function(){o.removeListener(e,n);for(var s=arguments.length,a=new Array(s),r=0;r<s;r++)a[r]=arguments[r];t.apply(o,a)};this.on(e,n)}
/**
   * @param {string} eventName
   * @param {Array} args
   */emit(e){for(var t=arguments.length,o=new Array(t>1?t-1:0),n=1;n<t;n++)o[n-1]=arguments[n];this._getHandlersByEventName(e).forEach((
/**
     * @param {EventHandler} eventHandler
     */
e=>{try{e.apply(this,o)}catch(e){console.error(e)}}))}
/**
   * @param {string} eventName
   * @param {EventHandler} eventHandler
   */removeListener(e,t){const o=this._getHandlersByEventName(e);const n=o.indexOf(t);n>-1&&o.splice(n,1)}
/**
   * @param {string} eventName
   */removeAllListeners(e){this.events[e]!==void 0&&(this.events[e].length=0)}reset(){this.events={}}}r.eventEmitter=new EventEmitter;
/**
 * @param {string} eventName
 * @param {EventHandler} eventHandler
 */const On=(e,t)=>{r.eventEmitter.on(e,t)};
/**
 * @param {string} eventName
 * @param {EventHandler} eventHandler
 */const jn=(e,t)=>{r.eventEmitter.once(e,t)};
/**
 * @param {string} [eventName]
 * @param {EventHandler} [eventHandler]
 */const Mn=(e,t)=>{e?t?r.eventEmitter.removeListener(e,t):r.eventEmitter.removeAllListeners(e):r.eventEmitter.reset()};var zn=Object.freeze({__proto__:null,argsToParams:vn,bindClickHandler:Sn,clickCancel:Pt,clickConfirm:Bt,clickDeny:Lt,enableLoading:wo,fire:yn,getActions:N,getCancelButton:I,getCloseButton:R,getConfirmButton:H,getContainer:E,getDenyButton:q,getFocusableElements:Y,getFooter:_,getHtmlContainer:O,getIcon:P,getIconContent:S,getImage:j,getInputLabel:D,getLoader:V,getPopup:L,getProgressSteps:M,getTimerLeft:xn,getTimerProgressBar:F,getTitle:T,getValidationMessage:z,increaseTimer:$n,isDeprecatedParameter:Jo,isLoading:K,isTimerRunning:Bn,isUpdatableParameter:Xo,isValidParameter:Ko,isVisible:$t,mixin:kn,off:Mn,on:On,once:jn,resumeTimer:An,showLoading:wo,stopTimer:Cn,toggleTimer:En});class Timer{
/**
   * @param {Function} callback
   * @param {number} delay
   */
constructor(e,t){this.callback=e;this.remaining=t;this.running=false;this.start()}
/**
   * @returns {number}
   */start(){if(!this.running){this.running=true;this.started=new Date;this.id=setTimeout(this.callback,this.remaining)}return this.remaining}
/**
   * @returns {number}
   */stop(){if(this.started&&this.running){this.running=false;clearTimeout(this.id);this.remaining-=(new Date).getTime()-this.started.getTime()}return this.remaining}
/**
   * @param {number} n
   * @returns {number}
   */increase(e){const t=this.running;t&&this.stop();this.remaining+=e;t&&this.start();return this.remaining}
/**
   * @returns {number}
   */getTimerLeft(){if(this.running){this.stop();this.start()}return this.remaining}
/**
   * @returns {boolean}
   */isRunning(){return this.running}}const Hn=["swal-title","swal-html","swal-footer"];
/**
 * @param {SweetAlertOptions} params
 * @returns {SweetAlertOptions}
 */const In=e=>{const t=typeof e.template==="string"?/** @type {HTMLTemplateElement} */document.querySelector(e.template):e.template;if(!t)return{};
/** @type {DocumentFragment} */const o=t.content;Un(o);const n=Object.assign(qn(o),Dn(o),Vn(o),Nn(o),_n(o),Fn(o),Rn(o,Hn));return n};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Record<string, any>}
 */const qn=e=>{
/** @type {Record<string, any>} */
const t={};
/** @type {HTMLElement[]} */const o=Array.from(e.querySelectorAll("swal-param"));o.forEach((e=>{Yn(e,["name","value"]);const o=/** @type {keyof SweetAlertOptions} */e.getAttribute("name");const n=e.getAttribute("value");o&&n&&(typeof Uo[o]==="boolean"?t[o]=n!=="false":typeof Uo[o]==="object"?t[o]=JSON.parse(n):t[o]=n)}));return t};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Record<string, any>}
 */const Dn=e=>{
/** @type {Record<string, any>} */
const t={};
/** @type {HTMLElement[]} */const o=Array.from(e.querySelectorAll("swal-function-param"));o.forEach((e=>{const o=/** @type {keyof SweetAlertOptions} */e.getAttribute("name");const n=e.getAttribute("value");o&&n&&(t[o]=new Function(`return ${n}`)())}));return t};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Record<string, any>}
 */const Vn=e=>{
/** @type {Record<string, any>} */
const t={};
/** @type {HTMLElement[]} */const o=Array.from(e.querySelectorAll("swal-button"));o.forEach((e=>{Yn(e,["type","color","aria-label"]);const o=e.getAttribute("type");if(o&&["confirm","cancel","deny"].includes(o)){t[`${o}ButtonText`]=e.innerHTML;t[`show${h(o)}Button`]=true;e.hasAttribute("color")&&(t[`${o}ButtonColor`]=e.getAttribute("color"));e.hasAttribute("aria-label")&&(t[`${o}ButtonAriaLabel`]=e.getAttribute("aria-label"))}}));return t};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Pick<SweetAlertOptions, 'imageUrl' | 'imageWidth' | 'imageHeight' | 'imageAlt'>}
 */const Nn=e=>{const t={};
/** @type {HTMLElement | null} */const o=e.querySelector("swal-image");if(o){Yn(o,["src","width","height","alt"]);o.hasAttribute("src")&&(t.imageUrl=o.getAttribute("src")||void 0);o.hasAttribute("width")&&(t.imageWidth=o.getAttribute("width")||void 0);o.hasAttribute("height")&&(t.imageHeight=o.getAttribute("height")||void 0);o.hasAttribute("alt")&&(t.imageAlt=o.getAttribute("alt")||void 0)}return t};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Record<string, any>}
 */const _n=e=>{const t={};
/** @type {HTMLElement | null} */const o=e.querySelector("swal-icon");if(o){Yn(o,["type","color"]);o.hasAttribute("type")&&(t.icon=o.getAttribute("type"));o.hasAttribute("color")&&(t.iconColor=o.getAttribute("color"));t.iconHtml=o.innerHTML}return t};
/**
 * @param {DocumentFragment} templateContent
 * @returns {Record<string, any>}
 */const Fn=e=>{
/** @type {Record<string, any>} */
const t={};
/** @type {HTMLElement | null} */const o=e.querySelector("swal-input");if(o){Yn(o,["type","label","placeholder","value"]);t.input=o.getAttribute("type")||"text";o.hasAttribute("label")&&(t.inputLabel=o.getAttribute("label"));o.hasAttribute("placeholder")&&(t.inputPlaceholder=o.getAttribute("placeholder"));o.hasAttribute("value")&&(t.inputValue=o.getAttribute("value"))}
/** @type {HTMLElement[]} */const n=Array.from(e.querySelectorAll("swal-input-option"));if(n.length){t.inputOptions={};n.forEach((e=>{Yn(e,["value"]);const o=e.getAttribute("value");if(!o)return;const n=e.innerHTML;t.inputOptions[o]=n}))}return t};
/**
 * @param {DocumentFragment} templateContent
 * @param {string[]} paramNames
 * @returns {Record<string, any>}
 */const Rn=(e,t)=>{
/** @type {Record<string, any>} */
const o={};for(const n in t){const s=t[n];
/** @type {HTMLElement | null} */const a=e.querySelector(s);if(a){Yn(a,[]);o[s.replace(/^swal-/,"")]=a.innerHTML.trim()}}return o};
/**
 * @param {DocumentFragment} templateContent
 */const Un=e=>{const t=Hn.concat(["swal-param","swal-function-param","swal-button","swal-image","swal-icon","swal-input","swal-input-option"]);Array.from(e.children).forEach((e=>{const o=e.tagName.toLowerCase();t.includes(o)||g(`Unrecognized element <${o}>`)}))};
/**
 * @param {HTMLElement} el
 * @param {string[]} allowedAttributes
 */const Yn=(e,t)=>{Array.from(e.attributes).forEach((o=>{t.indexOf(o.name)===-1&&g([`Unrecognized attribute "${o.name}" on <${e.tagName.toLowerCase()}>.`,""+(t.length?`Allowed attributes are: ${t.join(", ")}`:"To set the value, use HTML within the element.")])}))};const Wn=10;
/**
 * Open popup, add necessary classes and styles, fix scrollbar
 *
 * @param {SweetAlertOptions} params
 */const Zn=e=>{const t=E();const o=L();typeof e.willOpen==="function"&&e.willOpen(o);r.eventEmitter.emit("willOpen",o);const n=window.getComputedStyle(document.body);const s=n.overflowY;Gn(t,o,e);setTimeout((()=>{Xn(t,o)}),Wn);if(W()){Jn(t,e.scrollbarPadding,s);_t()}Z()||r.previousActiveElement||(r.previousActiveElement=document.activeElement);typeof e.didOpen==="function"&&setTimeout((()=>e.didOpen(o)));r.eventEmitter.emit("didOpen",o);se(t,u["no-transition"])};
/**
 * @param {AnimationEvent} event
 */const Kn=e=>{const t=L();if(e.target!==t)return;const o=E();t.removeEventListener("animationend",Kn);t.removeEventListener("transitionend",Kn);o.style.overflowY="auto"};
/**
 * @param {HTMLElement} container
 * @param {HTMLElement} popup
 */const Xn=(e,t)=>{if(he(t)){e.style.overflowY="hidden";t.addEventListener("animationend",Kn);t.addEventListener("transitionend",Kn)}else e.style.overflowY="auto"};
/**
 * @param {HTMLElement} container
 * @param {boolean} scrollbarPadding
 * @param {string} initialBodyOverflow
 */const Jn=(e,t,o)=>{Ut();t&&o!=="hidden"&&Qt(o);setTimeout((()=>{e.scrollTop=0}))};
/**
 * @param {HTMLElement} container
 * @param {HTMLElement} popup
 * @param {SweetAlertOptions} params
 */const Gn=(e,t,o)=>{ne(e,o.showClass.backdrop);if(o.animation){t.style.setProperty("opacity","0","important");ie(t,"grid");setTimeout((()=>{ne(t,o.showClass.popup);t.style.removeProperty("opacity")}),Wn)}else ie(t,"grid");ne([document.documentElement,document.body],u.shown);o.heightAuto&&o.backdrop&&!o.toast&&ne([document.documentElement,document.body],u["height-auto"])};var Qn={
/**
   * @param {string} string
   * @param {string} [validationMessage]
   * @returns {Promise<string | void>}
   */
email:(e,t)=>/^[a-zA-Z0-9.+_'-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9-]+$/.test(e)?Promise.resolve():Promise.resolve(t||"Invalid email address"),
/**
   * @param {string} string
   * @param {string} [validationMessage]
   * @returns {Promise<string | void>}
   */
url:(e,t)=>/^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-z]{2,63}\b([-a-zA-Z0-9@:%_+.~#?&/=]*)$/.test(e)?Promise.resolve():Promise.resolve(t||"Invalid URL")};
/**
 * @param {SweetAlertOptions} params
 */function es(e){if(!e.inputValidator){e.input==="email"&&(e.inputValidator=Qn.email);e.input==="url"&&(e.inputValidator=Qn.url)}}
/**
 * @param {SweetAlertOptions} params
 */function ts(e){if(!e.target||typeof e.target==="string"&&!document.querySelector(e.target)||typeof e.target!=="string"&&!e.target.appendChild){g('Target parameter is not valid, defaulting to "body"');e.target="body"}}
/**
 * Set type, text and actions on popup
 *
 * @param {SweetAlertOptions} params
 */function os(e){es(e);e.showLoaderOnConfirm&&!e.preConfirm&&g("showLoaderOnConfirm is set to true, but preConfirm is not defined.\nshowLoaderOnConfirm should be used together with preConfirm, see usage example:\nhttps://sweetalert2.github.io/#ajax-request");ts(e);typeof e.title==="string"&&(e.title=e.title.split("\n").join("<br />"));$e(e)}
/** @type {SweetAlert} */let ns;var ss=new WeakMap;class SweetAlert{
/**
   * @param {...any} args
   * @this {SweetAlert}
   */
constructor(){
/**
     * @type {Promise<SweetAlertResult>}
     */
n(this,ss,void 0);if(typeof window==="undefined")return;ns=this;for(var e=arguments.length,t=new Array(e),o=0;o<e;o++)t[o]=arguments[o];const a=Object.freeze(this.constructor.argsToParams(t));
/** @type {Readonly<SweetAlertOptions>} */this.params=a;
/** @type {boolean} */this.isAwaitingPromise=false;s(ss,this,this._main(ns.params))}_main(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:{};tn(Object.assign({},t,e));if(r.currentInstance){const e=Nt.swalPromiseResolve.get(r.currentInstance);const{isAwaitingPromise:t}=r.currentInstance;r.currentInstance._destroy();t||e({isDismissed:true});W()&&Ft()}r.currentInstance=ns;const o=rs(e,t);os(o);Object.freeze(o);if(r.timeout){r.timeout.stop();delete r.timeout}clearTimeout(r.restoreFocusTimeout);const n=is(ns);Et(ns,o);De.innerParams.set(ns,o);return as(ns,n,o)}then(e){return o(ss,this).then(e)}finally(e){return o(ss,this).finally(e)}}
/**
 * @param {SweetAlert} instance
 * @param {DomCache} domCache
 * @param {SweetAlertOptions} innerParams
 * @returns {Promise}
 */const as=(e,t,o)=>new Promise(((n,s)=>{
/**
     * @param {DismissReason} dismiss
     */
const a=t=>{e.close({isDismissed:true,dismiss:t})};Nt.swalPromiseResolve.set(e,n);Nt.swalPromiseReject.set(e,s);t.confirmButton.onclick=()=>{Eo(e)};t.denyButton.onclick=()=>{$o(e)};t.cancelButton.onclick=()=>{Bo(e,a)};t.closeButton.onclick=()=>{a(St.close)};dn(o,t,a);Ot(r,o,a);po(e,o);Zn(o);ls(r,o,a);cs(t,o);setTimeout((()=>{t.container.scrollTop=0}))}));
/**
 * @param {SweetAlertOptions} userParams
 * @param {SweetAlertOptions} mixinParams
 * @returns {SweetAlertOptions}
 */const rs=(e,t)=>{const o=In(e);const n=Object.assign({},Uo,t,o,e);n.showClass=Object.assign({},Uo.showClass,n.showClass);n.hideClass=Object.assign({},Uo.hideClass,n.hideClass);if(n.animation===false){n.showClass={backdrop:"swal2-noanimation"};n.hideClass={}}return n};
/**
 * @param {SweetAlert} instance
 * @returns {DomCache}
 */const is=e=>{const t={popup:L(),container:E(),actions:N(),confirmButton:H(),denyButton:q(),cancelButton:I(),loader:V(),closeButton:R(),validationMessage:z(),progressSteps:M()};De.domCache.set(e,t);return t};
/**
 * @param {GlobalState} globalState
 * @param {SweetAlertOptions} innerParams
 * @param {Function} dismissWith
 */const ls=(e,t,o)=>{const n=F();le(n);if(t.timer){e.timeout=new Timer((()=>{o("timer");delete e.timeout}),t.timer);if(t.timerProgressBar){ie(n);Q(n,t,"timerProgressBar");setTimeout((()=>{e.timeout&&e.timeout.running&&ge(t.timer)}))}}};
/**
 * Initialize focus in the popup:
 *
 * 1. If `toast` is `true`, don't steal focus from the document.
 * 2. Else if there is an [autofocus] element, focus it.
 * 3. Else if `focusConfirm` is `true` and confirm button is visible, focus it.
 * 4. Else if `focusDeny` is `true` and deny button is visible, focus it.
 * 5. Else if `focusCancel` is `true` and cancel button is visible, focus it.
 * 6. Else focus the first focusable element in a popup (if any).
 *
 * @param {DomCache} domCache
 * @param {SweetAlertOptions} innerParams
 */const cs=(e,t)=>{if(!t.toast)if(k(t.allowEnterKey))ds(e)||us(e,t)||jt(-1,1);else{y("allowEnterKey");ws()}};
/**
 * @param {DomCache} domCache
 * @returns {boolean}
 */const ds=e=>{const t=Array.from(e.popup.querySelectorAll("[autofocus]"));for(const e of t)if(e instanceof HTMLElement&&we(e)){e.focus();return true}return false};
/**
 * @param {DomCache} domCache
 * @param {SweetAlertOptions} innerParams
 * @returns {boolean}
 */const us=(e,t)=>{if(t.focusDeny&&we(e.denyButton)){e.denyButton.focus();return true}if(t.focusCancel&&we(e.cancelButton)){e.cancelButton.focus();return true}if(t.focusConfirm&&we(e.confirmButton)){e.confirmButton.focus();return true}return false};const ws=()=>{document.activeElement instanceof HTMLElement&&typeof document.activeElement.blur==="function"&&document.activeElement.blur()};SweetAlert.prototype.disableButtons=Vo;SweetAlert.prototype.enableButtons=Do;SweetAlert.prototype.getInput=Ho;SweetAlert.prototype.disableInput=_o;SweetAlert.prototype.enableInput=No;SweetAlert.prototype.hideLoading=Mo;SweetAlert.prototype.disableLoading=Mo;SweetAlert.prototype.showValidationMessage=Fo;SweetAlert.prototype.resetValidationMessage=Ro;SweetAlert.prototype.close=no;SweetAlert.prototype.closePopup=no;SweetAlert.prototype.closeModal=no;SweetAlert.prototype.closeToast=no;SweetAlert.prototype.rejectPromise=ao;SweetAlert.prototype.update=on;SweetAlert.prototype._destroy=sn;Object.assign(SweetAlert,zn);Object.keys(cn).forEach((e=>{
/**
   * @param {...any} args
   * @returns {any | undefined}
   */
SweetAlert[e]=function(){return ns&&ns[e]?ns[e](...arguments):null}}));SweetAlert.DismissReason=St;SweetAlert.version="11.18.0";const ms=SweetAlert;ms.default=ms;"undefined"!=typeof document&&function(e,t){var o=e.createElement("style");if(e.getElementsByTagName("head")[0].appendChild(o),o.styleSheet)o.styleSheet.disabled||(o.styleSheet.cssText=t);else try{o.innerHTML=t}catch(e){o.innerText=t}}(document,':root{--swal2-container-padding: 0.625em;--swal2-backdrop: rgba(0, 0, 0, 0.4);--swal2-width: 32em;--swal2-padding: 0 0 1.25em;--swal2-border: none;--swal2-border-radius: 0.3125rem;--swal2-background: white;--swal2-color: #545454;--swal2-footer-border-color: #eee;--swal2-show-animation: swal2-show 0.3s;--swal2-hide-animation: swal2-hide 0.15s forwards;--swal2-title-padding: 0.8em 1em 0;--swal2-html-container-padding: 1em 1.6em 0.3em;--swal2-input-background: transparent;--swal2-progress-step-background: #add8e6;--swal2-validation-message-background: #f0f0f0;--swal2-validation-message-color: #666;--swal2-close-button-position: initial;--swal2-close-button-inset: auto;--swal2-close-button-font-size: 2.5em;--swal2-close-button-color: #ccc;--swal2-close-button-transition: color 0.1s, box-shadow 0.1s;--swal2-close-button-outline: initial;--swal2-close-button-hover-transform: none}[data-swal2-theme=dark]{--swal2-dark-theme-black: #19191a;--swal2-dark-theme-white: #e1e1e1;--swal2-background: var(--swal2-dark-theme-black);--swal2-color: var(--swal2-dark-theme-white);--swal2-footer-border-color: #555;--swal2-input-background: color-mix(in srgb, var(--swal2-dark-theme-black), var(--swal2-dark-theme-white) 10%);--swal2-validation-message-background: color-mix( in srgb, var(--swal2-dark-theme-black), var(--swal2-dark-theme-white) 10% );--swal2-validation-message-color: var(--swal2-dark-theme-white)}@media(prefers-color-scheme: dark){[data-swal2-theme=auto]{--swal2-dark-theme-black: #19191a;--swal2-dark-theme-white: #e1e1e1;--swal2-background: var(--swal2-dark-theme-black);--swal2-color: var(--swal2-dark-theme-white);--swal2-footer-border-color: #555;--swal2-input-background: color-mix(in srgb, var(--swal2-dark-theme-black), var(--swal2-dark-theme-white) 10%);--swal2-validation-message-background: color-mix( in srgb, var(--swal2-dark-theme-black), var(--swal2-dark-theme-white) 10% );--swal2-validation-message-color: var(--swal2-dark-theme-white)}}body.swal2-shown:not(.swal2-no-backdrop,.swal2-toast-shown){overflow:hidden}body.swal2-height-auto{height:auto !important}body.swal2-no-backdrop .swal2-container{background-color:rgba(0,0,0,0) !important;pointer-events:none}body.swal2-no-backdrop .swal2-container .swal2-popup{pointer-events:all}body.swal2-no-backdrop .swal2-container .swal2-modal{box-shadow:0 0 10px var(--swal2-backdrop)}body.swal2-toast-shown .swal2-container{box-sizing:border-box;width:360px;max-width:100%;background-color:rgba(0,0,0,0);pointer-events:none}body.swal2-toast-shown .swal2-container.swal2-top{inset:0 auto auto 50%;transform:translateX(-50%)}body.swal2-toast-shown .swal2-container.swal2-top-end,body.swal2-toast-shown .swal2-container.swal2-top-right{inset:0 0 auto auto}body.swal2-toast-shown .swal2-container.swal2-top-start,body.swal2-toast-shown .swal2-container.swal2-top-left{inset:0 auto auto 0}body.swal2-toast-shown .swal2-container.swal2-center-start,body.swal2-toast-shown .swal2-container.swal2-center-left{inset:50% auto auto 0;transform:translateY(-50%)}body.swal2-toast-shown .swal2-container.swal2-center{inset:50% auto auto 50%;transform:translate(-50%, -50%)}body.swal2-toast-shown .swal2-container.swal2-center-end,body.swal2-toast-shown .swal2-container.swal2-center-right{inset:50% 0 auto auto;transform:translateY(-50%)}body.swal2-toast-shown .swal2-container.swal2-bottom-start,body.swal2-toast-shown .swal2-container.swal2-bottom-left{inset:auto auto 0 0}body.swal2-toast-shown .swal2-container.swal2-bottom{inset:auto auto 0 50%;transform:translateX(-50%)}body.swal2-toast-shown .swal2-container.swal2-bottom-end,body.swal2-toast-shown .swal2-container.swal2-bottom-right{inset:auto 0 0 auto}@media print{body.swal2-shown:not(.swal2-no-backdrop,.swal2-toast-shown){overflow-y:scroll !important}body.swal2-shown:not(.swal2-no-backdrop,.swal2-toast-shown)>[aria-hidden=true]{display:none}body.swal2-shown:not(.swal2-no-backdrop,.swal2-toast-shown) .swal2-container{position:static !important}}div:where(.swal2-container){display:grid;position:fixed;z-index:1060;inset:0;box-sizing:border-box;grid-template-areas:"top-start     top            top-end" "center-start  center         center-end" "bottom-start  bottom-center  bottom-end";grid-template-rows:minmax(min-content, auto) minmax(min-content, auto) minmax(min-content, auto);height:100%;padding:var(--swal2-container-padding);overflow-x:hidden;transition:background-color .1s;-webkit-overflow-scrolling:touch}div:where(.swal2-container).swal2-backdrop-show,div:where(.swal2-container).swal2-noanimation{background:var(--swal2-backdrop)}div:where(.swal2-container).swal2-backdrop-hide{background:rgba(0,0,0,0) !important}div:where(.swal2-container).swal2-top-start,div:where(.swal2-container).swal2-center-start,div:where(.swal2-container).swal2-bottom-start{grid-template-columns:minmax(0, 1fr) auto auto}div:where(.swal2-container).swal2-top,div:where(.swal2-container).swal2-center,div:where(.swal2-container).swal2-bottom{grid-template-columns:auto minmax(0, 1fr) auto}div:where(.swal2-container).swal2-top-end,div:where(.swal2-container).swal2-center-end,div:where(.swal2-container).swal2-bottom-end{grid-template-columns:auto auto minmax(0, 1fr)}div:where(.swal2-container).swal2-top-start>.swal2-popup{align-self:start}div:where(.swal2-container).swal2-top>.swal2-popup{grid-column:2;place-self:start center}div:where(.swal2-container).swal2-top-end>.swal2-popup,div:where(.swal2-container).swal2-top-right>.swal2-popup{grid-column:3;place-self:start end}div:where(.swal2-container).swal2-center-start>.swal2-popup,div:where(.swal2-container).swal2-center-left>.swal2-popup{grid-row:2;align-self:center}div:where(.swal2-container).swal2-center>.swal2-popup{grid-column:2;grid-row:2;place-self:center center}div:where(.swal2-container).swal2-center-end>.swal2-popup,div:where(.swal2-container).swal2-center-right>.swal2-popup{grid-column:3;grid-row:2;place-self:center end}div:where(.swal2-container).swal2-bottom-start>.swal2-popup,div:where(.swal2-container).swal2-bottom-left>.swal2-popup{grid-column:1;grid-row:3;align-self:end}div:where(.swal2-container).swal2-bottom>.swal2-popup{grid-column:2;grid-row:3;place-self:end center}div:where(.swal2-container).swal2-bottom-end>.swal2-popup,div:where(.swal2-container).swal2-bottom-right>.swal2-popup{grid-column:3;grid-row:3;place-self:end end}div:where(.swal2-container).swal2-grow-row>.swal2-popup,div:where(.swal2-container).swal2-grow-fullscreen>.swal2-popup{grid-column:1/4;width:100%}div:where(.swal2-container).swal2-grow-column>.swal2-popup,div:where(.swal2-container).swal2-grow-fullscreen>.swal2-popup{grid-row:1/4;align-self:stretch}div:where(.swal2-container).swal2-no-transition{transition:none !important}div:where(.swal2-container) div:where(.swal2-popup){display:none;position:relative;box-sizing:border-box;grid-template-columns:minmax(0, 100%);width:var(--swal2-width);max-width:100%;padding:var(--swal2-padding);border:var(--swal2-border);border-radius:var(--swal2-border-radius);background:var(--swal2-background);color:var(--swal2-color);font-family:inherit;font-size:1rem}div:where(.swal2-container) div:where(.swal2-popup):focus{outline:none}div:where(.swal2-container) div:where(.swal2-popup).swal2-loading{overflow-y:hidden}div:where(.swal2-container) div:where(.swal2-popup).swal2-draggable{cursor:grab}div:where(.swal2-container) div:where(.swal2-popup).swal2-draggable div:where(.swal2-icon){cursor:grab}div:where(.swal2-container) div:where(.swal2-popup).swal2-dragging{cursor:grabbing}div:where(.swal2-container) div:where(.swal2-popup).swal2-dragging div:where(.swal2-icon){cursor:grabbing}div:where(.swal2-container) h2:where(.swal2-title){position:relative;max-width:100%;margin:0;padding:var(--swal2-title-padding);color:inherit;font-size:1.875em;font-weight:600;text-align:center;text-transform:none;word-wrap:break-word;cursor:initial}div:where(.swal2-container) div:where(.swal2-actions){display:flex;z-index:1;box-sizing:border-box;flex-wrap:wrap;align-items:center;justify-content:center;width:auto;margin:1.25em auto 0;padding:0}div:where(.swal2-container) div:where(.swal2-actions):not(.swal2-loading) .swal2-styled[disabled]{opacity:.4}div:where(.swal2-container) div:where(.swal2-actions):not(.swal2-loading) .swal2-styled:hover{background-image:linear-gradient(rgba(0, 0, 0, 0.1), rgba(0, 0, 0, 0.1))}div:where(.swal2-container) div:where(.swal2-actions):not(.swal2-loading) .swal2-styled:active{background-image:linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2))}div:where(.swal2-container) div:where(.swal2-loader){display:none;align-items:center;justify-content:center;width:2.2em;height:2.2em;margin:0 1.875em;animation:swal2-rotate-loading 1.5s linear 0s infinite normal;border-width:.25em;border-style:solid;border-radius:100%;border-color:#2778c4 rgba(0,0,0,0) #2778c4 rgba(0,0,0,0)}div:where(.swal2-container) button:where(.swal2-styled){margin:.3125em;padding:.625em 1.1em;transition:box-shadow .1s;box-shadow:0 0 0 3px rgba(0,0,0,0);font-weight:500}div:where(.swal2-container) button:where(.swal2-styled):not([disabled]){cursor:pointer}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-confirm){border:0;border-radius:.25em;background:initial;background-color:#7066e0;color:#fff;font-size:1em}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-confirm):focus-visible{box-shadow:0 0 0 3px rgba(112,102,224,.5)}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-deny){border:0;border-radius:.25em;background:initial;background-color:#dc3741;color:#fff;font-size:1em}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-deny):focus-visible{box-shadow:0 0 0 3px rgba(220,55,65,.5)}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-cancel){border:0;border-radius:.25em;background:initial;background-color:#6e7881;color:#fff;font-size:1em}div:where(.swal2-container) button:where(.swal2-styled):where(.swal2-cancel):focus-visible{box-shadow:0 0 0 3px rgba(110,120,129,.5)}div:where(.swal2-container) button:where(.swal2-styled).swal2-default-outline:focus-visible{box-shadow:0 0 0 3px rgba(100,150,200,.5)}div:where(.swal2-container) button:where(.swal2-styled):focus-visible{outline:none}div:where(.swal2-container) button:where(.swal2-styled)::-moz-focus-inner{border:0}div:where(.swal2-container) div:where(.swal2-footer){margin:1em 0 0;padding:1em 1em 0;border-top:1px solid var(--swal2-footer-border-color);color:inherit;font-size:1em;text-align:center;cursor:initial}div:where(.swal2-container) .swal2-timer-progress-bar-container{position:absolute;right:0;bottom:0;left:0;grid-column:auto !important;overflow:hidden;border-bottom-right-radius:var(--swal2-border-radius);border-bottom-left-radius:var(--swal2-border-radius)}div:where(.swal2-container) div:where(.swal2-timer-progress-bar){width:100%;height:.25em;background:rgba(0,0,0,.2)}div:where(.swal2-container) img:where(.swal2-image){max-width:100%;margin:2em auto 1em;cursor:initial}div:where(.swal2-container) button:where(.swal2-close){position:var(--swal2-close-button-position);inset:var(--swal2-close-button-inset);z-index:2;align-items:center;justify-content:center;width:1.2em;height:1.2em;margin-top:0;margin-right:0;margin-bottom:-1.2em;padding:0;overflow:hidden;transition:var(--swal2-close-button-transition);border:none;border-radius:var(--swal2-border-radius);outline:var(--swal2-close-button-outline);background:rgba(0,0,0,0);color:var(--swal2-close-button-color);font-family:monospace;font-size:var(--swal2-close-button-font-size);cursor:pointer;justify-self:end}div:where(.swal2-container) button:where(.swal2-close):hover{transform:var(--swal2-close-button-hover-transform);background:rgba(0,0,0,0);color:#f27474}div:where(.swal2-container) button:where(.swal2-close):focus-visible{outline:none;box-shadow:inset 0 0 0 3px rgba(100,150,200,.5)}div:where(.swal2-container) button:where(.swal2-close)::-moz-focus-inner{border:0}div:where(.swal2-container) div:where(.swal2-html-container){z-index:1;justify-content:center;margin:0;padding:var(--swal2-html-container-padding);overflow:auto;color:inherit;font-size:1.125em;font-weight:normal;line-height:normal;text-align:center;word-wrap:break-word;word-break:break-word;cursor:initial}div:where(.swal2-container) input:where(.swal2-input),div:where(.swal2-container) input:where(.swal2-file),div:where(.swal2-container) textarea:where(.swal2-textarea),div:where(.swal2-container) select:where(.swal2-select),div:where(.swal2-container) div:where(.swal2-radio),div:where(.swal2-container) label:where(.swal2-checkbox){margin:1em 2em 3px}div:where(.swal2-container) input:where(.swal2-input),div:where(.swal2-container) input:where(.swal2-file),div:where(.swal2-container) textarea:where(.swal2-textarea){box-sizing:border-box;width:auto;transition:border-color .1s,box-shadow .1s;border:1px solid #d9d9d9;border-radius:.1875em;background:var(--swal2-input-background);box-shadow:inset 0 1px 1px rgba(0,0,0,.06),0 0 0 3px rgba(0,0,0,0);color:inherit;font-size:1.125em}div:where(.swal2-container) input:where(.swal2-input).swal2-inputerror,div:where(.swal2-container) input:where(.swal2-file).swal2-inputerror,div:where(.swal2-container) textarea:where(.swal2-textarea).swal2-inputerror{border-color:#f27474 !important;box-shadow:0 0 2px #f27474 !important}div:where(.swal2-container) input:where(.swal2-input):focus,div:where(.swal2-container) input:where(.swal2-file):focus,div:where(.swal2-container) textarea:where(.swal2-textarea):focus{border:1px solid #b4dbed;outline:none;box-shadow:inset 0 1px 1px rgba(0,0,0,.06),0 0 0 3px rgba(100,150,200,.5)}div:where(.swal2-container) input:where(.swal2-input)::placeholder,div:where(.swal2-container) input:where(.swal2-file)::placeholder,div:where(.swal2-container) textarea:where(.swal2-textarea)::placeholder{color:#ccc}div:where(.swal2-container) .swal2-range{margin:1em 2em 3px;background:var(--swal2-background)}div:where(.swal2-container) .swal2-range input{width:80%}div:where(.swal2-container) .swal2-range output{width:20%;color:inherit;font-weight:600;text-align:center}div:where(.swal2-container) .swal2-range input,div:where(.swal2-container) .swal2-range output{height:2.625em;padding:0;font-size:1.125em;line-height:2.625em}div:where(.swal2-container) .swal2-input{height:2.625em;padding:0 .75em}div:where(.swal2-container) .swal2-file{width:75%;margin-right:auto;margin-left:auto;background:var(--swal2-input-background);font-size:1.125em}div:where(.swal2-container) .swal2-textarea{height:6.75em;padding:.75em}div:where(.swal2-container) .swal2-select{min-width:50%;max-width:100%;padding:.375em .625em;background:var(--swal2-input-background);color:inherit;font-size:1.125em}div:where(.swal2-container) .swal2-radio,div:where(.swal2-container) .swal2-checkbox{align-items:center;justify-content:center;background:var(--swal2-background);color:inherit}div:where(.swal2-container) .swal2-radio label,div:where(.swal2-container) .swal2-checkbox label{margin:0 .6em;font-size:1.125em}div:where(.swal2-container) .swal2-radio input,div:where(.swal2-container) .swal2-checkbox input{flex-shrink:0;margin:0 .4em}div:where(.swal2-container) label:where(.swal2-input-label){display:flex;justify-content:center;margin:1em auto 0}div:where(.swal2-container) div:where(.swal2-validation-message){align-items:center;justify-content:center;margin:1em 0 0;padding:.625em;overflow:hidden;background:var(--swal2-validation-message-background);color:var(--swal2-validation-message-color);font-size:1em;font-weight:300}div:where(.swal2-container) div:where(.swal2-validation-message)::before{content:"!";display:inline-block;width:1.5em;min-width:1.5em;height:1.5em;margin:0 .625em;border-radius:50%;background-color:#f27474;color:#fff;font-weight:600;line-height:1.5em;text-align:center}div:where(.swal2-container) .swal2-progress-steps{flex-wrap:wrap;align-items:center;max-width:100%;margin:1.25em auto;padding:0;background:rgba(0,0,0,0);font-weight:600}div:where(.swal2-container) .swal2-progress-steps li{display:inline-block;position:relative}div:where(.swal2-container) .swal2-progress-steps .swal2-progress-step{z-index:20;flex-shrink:0;width:2em;height:2em;border-radius:2em;background:#2778c4;color:#fff;line-height:2em;text-align:center}div:where(.swal2-container) .swal2-progress-steps .swal2-progress-step.swal2-active-progress-step{background:#2778c4}div:where(.swal2-container) .swal2-progress-steps .swal2-progress-step.swal2-active-progress-step~.swal2-progress-step{background:var(--swal2-progress-step-background);color:#fff}div:where(.swal2-container) .swal2-progress-steps .swal2-progress-step.swal2-active-progress-step~.swal2-progress-step-line{background:var(--swal2-progress-step-background)}div:where(.swal2-container) .swal2-progress-steps .swal2-progress-step-line{z-index:10;flex-shrink:0;width:2.5em;height:.4em;margin:0 -1px;background:#2778c4}div:where(.swal2-icon){position:relative;box-sizing:content-box;justify-content:center;width:5em;height:5em;margin:2.5em auto .6em;border:.25em solid rgba(0,0,0,0);border-radius:50%;border-color:#000;font-family:inherit;line-height:5em;cursor:default;user-select:none}div:where(.swal2-icon) .swal2-icon-content{display:flex;align-items:center;font-size:3.75em}div:where(.swal2-icon).swal2-error{border-color:#f27474;color:#f27474}div:where(.swal2-icon).swal2-error .swal2-x-mark{position:relative;flex-grow:1}div:where(.swal2-icon).swal2-error [class^=swal2-x-mark-line]{display:block;position:absolute;top:2.3125em;width:2.9375em;height:.3125em;border-radius:.125em;background-color:#f27474}div:where(.swal2-icon).swal2-error [class^=swal2-x-mark-line][class$=left]{left:1.0625em;transform:rotate(45deg)}div:where(.swal2-icon).swal2-error [class^=swal2-x-mark-line][class$=right]{right:1em;transform:rotate(-45deg)}div:where(.swal2-icon).swal2-error.swal2-icon-show{animation:swal2-animate-error-icon .5s}div:where(.swal2-icon).swal2-error.swal2-icon-show .swal2-x-mark{animation:swal2-animate-error-x-mark .5s}div:where(.swal2-icon).swal2-warning{border-color:#f8bb86;color:#f8bb86}div:where(.swal2-icon).swal2-warning.swal2-icon-show{animation:swal2-animate-error-icon .5s}div:where(.swal2-icon).swal2-warning.swal2-icon-show .swal2-icon-content{animation:swal2-animate-i-mark .5s}div:where(.swal2-icon).swal2-info{border-color:#3fc3ee;color:#3fc3ee}div:where(.swal2-icon).swal2-info.swal2-icon-show{animation:swal2-animate-error-icon .5s}div:where(.swal2-icon).swal2-info.swal2-icon-show .swal2-icon-content{animation:swal2-animate-i-mark .8s}div:where(.swal2-icon).swal2-question{border-color:#87adbd;color:#87adbd}div:where(.swal2-icon).swal2-question.swal2-icon-show{animation:swal2-animate-error-icon .5s}div:where(.swal2-icon).swal2-question.swal2-icon-show .swal2-icon-content{animation:swal2-animate-question-mark .8s}div:where(.swal2-icon).swal2-success{border-color:#a5dc86;color:#a5dc86}div:where(.swal2-icon).swal2-success [class^=swal2-success-circular-line]{position:absolute;width:3.75em;height:7.5em;border-radius:50%}div:where(.swal2-icon).swal2-success [class^=swal2-success-circular-line][class$=left]{top:-0.4375em;left:-2.0635em;transform:rotate(-45deg);transform-origin:3.75em 3.75em;border-radius:7.5em 0 0 7.5em}div:where(.swal2-icon).swal2-success [class^=swal2-success-circular-line][class$=right]{top:-0.6875em;left:1.875em;transform:rotate(-45deg);transform-origin:0 3.75em;border-radius:0 7.5em 7.5em 0}div:where(.swal2-icon).swal2-success .swal2-success-ring{position:absolute;z-index:2;top:-0.25em;left:-0.25em;box-sizing:content-box;width:100%;height:100%;border:.25em solid rgba(165,220,134,.3);border-radius:50%}div:where(.swal2-icon).swal2-success .swal2-success-fix{position:absolute;z-index:1;top:.5em;left:1.625em;width:.4375em;height:5.625em;transform:rotate(-45deg)}div:where(.swal2-icon).swal2-success [class^=swal2-success-line]{display:block;position:absolute;z-index:2;height:.3125em;border-radius:.125em;background-color:#a5dc86}div:where(.swal2-icon).swal2-success [class^=swal2-success-line][class$=tip]{top:2.875em;left:.8125em;width:1.5625em;transform:rotate(45deg)}div:where(.swal2-icon).swal2-success [class^=swal2-success-line][class$=long]{top:2.375em;right:.5em;width:2.9375em;transform:rotate(-45deg)}div:where(.swal2-icon).swal2-success.swal2-icon-show .swal2-success-line-tip{animation:swal2-animate-success-line-tip .75s}div:where(.swal2-icon).swal2-success.swal2-icon-show .swal2-success-line-long{animation:swal2-animate-success-line-long .75s}div:where(.swal2-icon).swal2-success.swal2-icon-show .swal2-success-circular-line-right{animation:swal2-rotate-success-circular-line 4.25s ease-in}[class^=swal2]{-webkit-tap-highlight-color:rgba(0,0,0,0)}.swal2-show{animation:var(--swal2-show-animation)}.swal2-hide{animation:var(--swal2-hide-animation)}.swal2-noanimation{transition:none}.swal2-scrollbar-measure{position:absolute;top:-9999px;width:50px;height:50px;overflow:scroll}.swal2-rtl .swal2-close{margin-right:initial;margin-left:0}.swal2-rtl .swal2-timer-progress-bar{right:0;left:auto}.swal2-toast{box-sizing:border-box;grid-column:1/4 !important;grid-row:1/4 !important;grid-template-columns:min-content auto min-content;padding:1em;overflow-y:hidden;background:var(--swal2-background);box-shadow:0 0 1px rgba(0,0,0,.075),0 1px 2px rgba(0,0,0,.075),1px 2px 4px rgba(0,0,0,.075),1px 3px 8px rgba(0,0,0,.075),2px 4px 16px rgba(0,0,0,.075);pointer-events:all}.swal2-toast>*{grid-column:2}.swal2-toast h2:where(.swal2-title){margin:.5em 1em;padding:0;font-size:1em;text-align:initial}.swal2-toast .swal2-loading{justify-content:center}.swal2-toast input:where(.swal2-input){height:2em;margin:.5em;font-size:1em}.swal2-toast .swal2-validation-message{font-size:1em}.swal2-toast div:where(.swal2-footer){margin:.5em 0 0;padding:.5em 0 0;font-size:.8em}.swal2-toast button:where(.swal2-close){grid-column:3/3;grid-row:1/99;align-self:center;width:.8em;height:.8em;margin:0;font-size:2em}.swal2-toast div:where(.swal2-html-container){margin:.5em 1em;padding:0;overflow:initial;font-size:1em;text-align:initial}.swal2-toast div:where(.swal2-html-container):empty{padding:0}.swal2-toast .swal2-loader{grid-column:1;grid-row:1/99;align-self:center;width:2em;height:2em;margin:.25em}.swal2-toast .swal2-icon{grid-column:1;grid-row:1/99;align-self:center;width:2em;min-width:2em;height:2em;margin:0 .5em 0 0}.swal2-toast .swal2-icon .swal2-icon-content{display:flex;align-items:center;font-size:1.8em;font-weight:bold}.swal2-toast .swal2-icon.swal2-success .swal2-success-ring{width:2em;height:2em}.swal2-toast .swal2-icon.swal2-error [class^=swal2-x-mark-line]{top:.875em;width:1.375em}.swal2-toast .swal2-icon.swal2-error [class^=swal2-x-mark-line][class$=left]{left:.3125em}.swal2-toast .swal2-icon.swal2-error [class^=swal2-x-mark-line][class$=right]{right:.3125em}.swal2-toast div:where(.swal2-actions){justify-content:flex-start;height:auto;margin:0;margin-top:.5em;padding:0 .5em}.swal2-toast button:where(.swal2-styled){margin:.25em .5em;padding:.4em .6em;font-size:1em}.swal2-toast .swal2-success{border-color:#a5dc86}.swal2-toast .swal2-success [class^=swal2-success-circular-line]{position:absolute;width:1.6em;height:3em;border-radius:50%}.swal2-toast .swal2-success [class^=swal2-success-circular-line][class$=left]{top:-0.8em;left:-0.5em;transform:rotate(-45deg);transform-origin:2em 2em;border-radius:4em 0 0 4em}.swal2-toast .swal2-success [class^=swal2-success-circular-line][class$=right]{top:-0.25em;left:.9375em;transform-origin:0 1.5em;border-radius:0 4em 4em 0}.swal2-toast .swal2-success .swal2-success-ring{width:2em;height:2em}.swal2-toast .swal2-success .swal2-success-fix{top:0;left:.4375em;width:.4375em;height:2.6875em}.swal2-toast .swal2-success [class^=swal2-success-line]{height:.3125em}.swal2-toast .swal2-success [class^=swal2-success-line][class$=tip]{top:1.125em;left:.1875em;width:.75em}.swal2-toast .swal2-success [class^=swal2-success-line][class$=long]{top:.9375em;right:.1875em;width:1.375em}.swal2-toast .swal2-success.swal2-icon-show .swal2-success-line-tip{animation:swal2-toast-animate-success-line-tip .75s}.swal2-toast .swal2-success.swal2-icon-show .swal2-success-line-long{animation:swal2-toast-animate-success-line-long .75s}.swal2-toast.swal2-show{animation:swal2-toast-show .5s}.swal2-toast.swal2-hide{animation:swal2-toast-hide .1s forwards}@keyframes swal2-show{0%{transform:scale(0.7)}45%{transform:scale(1.05)}80%{transform:scale(0.95)}100%{transform:scale(1)}}@keyframes swal2-hide{0%{transform:scale(1);opacity:1}100%{transform:scale(0.5);opacity:0}}@keyframes swal2-animate-success-line-tip{0%{top:1.1875em;left:.0625em;width:0}54%{top:1.0625em;left:.125em;width:0}70%{top:2.1875em;left:-0.375em;width:3.125em}84%{top:3em;left:1.3125em;width:1.0625em}100%{top:2.8125em;left:.8125em;width:1.5625em}}@keyframes swal2-animate-success-line-long{0%{top:3.375em;right:2.875em;width:0}65%{top:3.375em;right:2.875em;width:0}84%{top:2.1875em;right:0;width:3.4375em}100%{top:2.375em;right:.5em;width:2.9375em}}@keyframes swal2-rotate-success-circular-line{0%{transform:rotate(-45deg)}5%{transform:rotate(-45deg)}12%{transform:rotate(-405deg)}100%{transform:rotate(-405deg)}}@keyframes swal2-animate-error-x-mark{0%{margin-top:1.625em;transform:scale(0.4);opacity:0}50%{margin-top:1.625em;transform:scale(0.4);opacity:0}80%{margin-top:-0.375em;transform:scale(1.15)}100%{margin-top:0;transform:scale(1);opacity:1}}@keyframes swal2-animate-error-icon{0%{transform:rotateX(100deg);opacity:0}100%{transform:rotateX(0deg);opacity:1}}@keyframes swal2-rotate-loading{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}@keyframes swal2-animate-question-mark{0%{transform:rotateY(-360deg)}100%{transform:rotateY(0)}}@keyframes swal2-animate-i-mark{0%{transform:rotateZ(45deg);opacity:0}25%{transform:rotateZ(-25deg);opacity:.4}50%{transform:rotateZ(15deg);opacity:.8}75%{transform:rotateZ(-5deg);opacity:1}100%{transform:rotateX(0);opacity:1}}@keyframes swal2-toast-show{0%{transform:translateY(-0.625em) rotateZ(2deg)}33%{transform:translateY(0) rotateZ(-2deg)}66%{transform:translateY(0.3125em) rotateZ(2deg)}100%{transform:translateY(0) rotateZ(0deg)}}@keyframes swal2-toast-hide{100%{transform:rotateZ(1deg);opacity:0}}@keyframes swal2-toast-animate-success-line-tip{0%{top:.5625em;left:.0625em;width:0}54%{top:.125em;left:.125em;width:0}70%{top:.625em;left:-0.25em;width:1.625em}84%{top:1.0625em;left:.75em;width:.5em}100%{top:1.125em;left:.1875em;width:.75em}}@keyframes swal2-toast-animate-success-line-long{0%{top:1.625em;right:1.375em;width:0}65%{top:1.25em;right:.9375em;width:0}84%{top:.9375em;right:0;width:1.125em}100%{top:.9375em;right:.1875em;width:1.375em}}');export{ms as default};

