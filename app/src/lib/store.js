import { readable, writable } from "svelte/store";
import { ethers } from "ethers";

import containerArtifact from '../../../deployments/localhost/LoogieTank.json';
import entitiesArtifact from '../../../deployments/localhost/TreasureEntities.json';

export const CONTAINER_ADDRESS = "0xc1AeB096b97D27e118A446147D0b0e181845eA85";


export const account = writable(null);
export const provider = writable(null);

export const containerContract = writable(null);
export const localContainerContract = readable(null, (set) => {
  const baseProvider = new ethers.providers.JsonRpcProvider();
  set(new ethers.Contract(CONTAINER_ADDRESS, containerArtifact.abi, baseProvider));
});

export const entitiesContract = writable(null);
export const localEntitiesContract = writable( null);

export const containers = writable([]);
export const containerTypes = writable([])
