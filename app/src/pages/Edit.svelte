<script>
  import { onMount } from "svelte";

  import { containers } from "../lib/store.js";
  import { account } from "../lib/store.js";

  let currentIndex = 0;


  onMount(() => {
    const split = document.location.hash.split('/');

    if (split.length === 2) {
      currentIndex = split[1];
    }
  })
</script>


<style>
  #action {
    display: flex;
    gap: 5px;
  }
</style>


{#if ($account)}
  <section id='action'>
    <button>Load Gold</button>
    <button>Load Silver</button>
    <button>Load Elixir</button>
  </section>

  {@html $containers[currentIndex]?.image}
{/if}
