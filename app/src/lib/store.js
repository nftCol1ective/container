import { readable, writable } from "svelte/store";
import { ethers } from "ethers";

import containerArtifact from '../../../deployments/localhost/LoogieTank.json';
import entitiesArtifact from '../../../deployments/localhost/TreasureEntities.json';

export const CONTAINER_ADDRESS = "0x9f1ad226923A035bA09d964Edf9392B89d53Fc44";


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
