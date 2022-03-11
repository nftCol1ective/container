<script>
  import { onMount } from "svelte";

  import { containers } from "../lib/store.js";

  export let entitiesArtifact;


  let currentIndex = 0;


  onMount(() => {
    const split = document.location.hash.split('/');

    if (split.length === 2) {
      currentIndex = Number.parseInt(split[1]);
    }
  })
</script>


<style>
  #action {
    display: flex;
    gap: 5px;
  }
</style>


  <section id='action'>
    <div>
      <button>-</button>
      <span>Gold</span>
      <button>+</button>
    </div>
    <div>
      <button>-</button>
      <span>Silver</span>
      <button>+</button>
    </div>
    <div>
      <button>-</button>
      <span>Elixir</span>
      <button>+</button>
    </div>
  </section>

  {@html $containers[currentIndex]?.image}
