<script>
  import { onMount, createEventDispatcher } from 'svelte';
  import { decodeTokenUri } from "../lib/utils.js";

  import {
    containers,
    localContainerContract,
    containerTypes,
    entitiesContract
  } from "../lib/store.js";


  const dispatcher = createEventDispatcher();

  let containerType = '0';
  let selectedTokens = [];


  onMount(async () => {
    if ($containerTypes.length === 0) {
      $containerTypes = await $localContainerContract.getContainerTypes();
    }
  })

  async function requestAvailableEntities() {
    const encoded = await $entitiesContract.getAvailableEntityMetadata();
    return encoded.map((item => {
      decodeTokenUri(item);
    }))
  }

  function handleTypeSelection(event) {
    containerType = event.target.value;

    // TODO: Get the available tokens per container type from some datasource, ABI for example

    selectedTokens = [];
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
      on:click={() => dispatcher('setupContainer', {type: containerType, tokens: selectedTokens})}
      disabled="{containerType === '0'}"
    >Setup container</button>
</section>
<label>
  <span>Container type</span>
  <select on:change={handleTypeSelection}>
    <option value="0">--choose--</option>
    {#each $containerTypes as type, index}
      <option value="{index + 1}">{type}</option>
    {/each}
  </select>
</label>
<div>
  <p>Token set (different for every container type)</p>
  {#if containerType === '1'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0' />
      <span>Gold</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1'/>
      <span>Silver</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2'/>
      <span>Elixir</span>
    </label>
  {:else if containerType === '2'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0' />
      <span>Admin</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1' />
      <span>Mentor</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2'/>
      <span>Contributor</span>
    </label>
  {:else if containerType === '3'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0' />
      <span>Abstract background</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1'/>
      <span>Forest</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2' />
      <span>Daylight</span>
    </label>
  {:else if containerType === '4'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0' />
      <span>Hospitality</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1' />
      <span>Greet&Meet</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2' />
      <span>Merchandise</span>
    </label>
  {:else if containerType === '5'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0'/>
      <span>Car</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1'/>
      <span>House</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2'/>
      <span>Boat</span>
    </label>
  {:else if containerType === '6'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0'/>
      <span>Developer</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1'/>
      <span>Contributor</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2'/>
      <span>Certified</span>
    </label>
  {:else if containerType === '7'}
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='0'/>
      <span>Abstrat Art</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='1'/>
      <span>Magic</span>
    </label>
    <label>
      <input type="checkbox" bind:group={selectedTokens} name="{containerType}" value='2'/>
      <span>POAP</span>
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

