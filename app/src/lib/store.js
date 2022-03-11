import { writable } from "svelte/store";
import { ethers } from "ethers";

import containerArtifact from '../../../deployments/localhost/LoogieTank.json';
import entitiesArtifact from '../../../deployments/localhost/TreasureEntities.json';

export const CONTAINER_ADDRESS = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";


export const account = writable(null);
export const provider = writable(null);

export const containerContract = writable(null);
export const localContainerContract = writable(null, (set) => {
  const baseProvider = new ethers.providers.JsonRpcProvider();
  set(new ethers.Contract(CONTAINER_ADDRESS, containerArtifact.abi, baseProvider));
});

export const entitiesContract = writable(null);
export const localEntitiesContract = writable(null);

export const containers = writable([]);
export const containerTypes = writable([])
