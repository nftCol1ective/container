import { writable } from "svelte/store";


export const account = writable(null);
export const provider = writable(null);

export const containerAddress= writable(null);
export const containerContract = writable(null);

export const entitiesContract = writable(null);
export const entitiesAddress = writable(null);

export const containers = writable([]);
