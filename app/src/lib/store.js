import { writable } from "svelte/store";


export const account = writable(null);
export const contract = writable(null);
export const provider = writable(null);
export const containers = writable([]);
