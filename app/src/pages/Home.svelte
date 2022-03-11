<script>
  import { createEventDispatcher } from 'svelte';

  import { containers, containerContract, entitiesContract } from "../lib/store.js";
  import { decodeTokenUri } from "../lib/utils.js";

  export let hasContainer;

  let dispatcher = createEventDispatcher();

  let containerType;


  async function requestAvailableEntities() {
    const encoded = await $entitiesContract.getAvailableEntityMetadata();
    return encoded.map((item => {
      decodeTokenUri(item);
    }))
  }

  export async function handleCreateContainer() {
    console.log('creating');

    const tx = await $containerContract.setupNewContainer();
    await tx.wait();

    hasContainer = true;
    window.location.hash = `edit/${tx.id}`;
  }

</script>


<style>
  #action {
    display: flex;
    gap: 5px;
  }

  #list {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 15px;

    list-style: none;
  }
</style>


<section id="action">
    <button
      on:click={handleCreateContainer}
      disabled="{containerType === '0'}"
    >Create container</button>
</section>
<label>
  <span>Container type</span>
  <select bind:value={containerType}>
    <option value="0">--choose--</option>
    <option value="1">Gaming</option>
    <option value="2">Membership</option>
    <option value="3">Art</option>
    <option value="4">Ticket</option>
    <option value="5">Ownership</option>
    <option value="6">Avatar</option>
    <option value="7">Collection</option>
  </select>
</label>
<div>
  <p>Token set (different for every container type)</p>
  {#if containerType === '1'}
    <label>
      <span>Gold</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Silver</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Elixir</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '2'}
    <label>
      <span>Admin</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Mentor</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Contributor</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '3'}
    <label>
      <span>Abstract background</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Forest</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Daylight</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '4'}
    <label>
      <span>Hospitality</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Greet&Meet</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Merchandise</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '5'}
    <label>
      <span>Car</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>House</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Boat</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '6'}
    <label>
      <span>Developer</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Contributor</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Certified</span>
      <input type="checkbox"/>
    </label>
  {:else if containerType === '7'}
    <label>
      <span>Abstrat Art</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>Magic</span>
      <input type="checkbox"/>
    </label>
    <label>
      <span>POAP</span>
      <input type="checkbox"/>
    </label>
  {/if}
</div>

<ul id="list">
  {#each $containers as container, index}
      <li on:click={() => document.location.hash = `edit/${container.id}`}>
        {@html container.image}
        <p>{container.name}</p>
      </li>
  {/each}
</ul>

