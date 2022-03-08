<script>
  import { createEventDispatcher } from 'svelte';

  import { account, containers } from "../lib/store.js";


  export let hasContainer;

  let dispatcher = createEventDispatcher();
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
  {#if ($account)}
    <button on:click={() => dispatcher('createContainer')}>Create container</button>
    {#if hasContainer}
      <button on:click={() => dispatcher('loadContainers')}>Load Container</button>
    {/if}
  {/if}
</section>
<ul id="list">
  {#each $containers as container, index}
      <li on:click={() => document.location.hash = `edit/${index}`}>
        {@html container.image}
        <p>{container.name}</p>
      </li>
  {/each}
</ul>

