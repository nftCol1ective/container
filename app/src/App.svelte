<script>
  import { onMount } from 'svelte';

  import containerArtifact from '../../artifacts/src/Container/LoogieTank.sol/LoogieTank.json'

  import { sequence } from '0xsequence'
  import { ethers } from "ethers";


  const containerAddress = "0x74F69ee412A1C4Ed55634565e809DaF2ECFdE61D";

  let wallet, isConnected = false;
  let display, displayLoaded = false;


  onMount(() => {
    wallet = new sequence.Wallet('rinkeby');
    isConnected = wallet.isConnected();

    wallet.on('message', message => {
      console.log('wallet event (message):', message)
    })

    wallet.on('accountsChanged', p => {
      console.log('wallet event (accountsChanged):', p)
    })

    wallet.on('chainChanged', p => {
      console.log('wallet event (chainChanged):', p)
    })

    wallet.on('connect', p => {
      console.log('wallet event (connect):', p);

      isConnected = true;
    })

    wallet.on('disconnect', p => {
      console.log('wallet event (disconnect):', p);

      isConnected = false;
    })

    wallet.on('open', p => {
      console.log('wallet event (open):', p)
    })

    wallet.on('close', p => {
      console.log('wallet event (close):', p)
    })
  })

  function handleConnectWallet() {
    wallet.connect({
      app: "Composable NFT"
    });
  }

  function handleDisconnectWallet() {
    wallet.disconnect();
    isConnected = false;
  }

  async function handleLoadContainer() {
    console.log('loading');

    const provider = wallet.getProvider();

    const containerContract = new ethers.Contract(containerAddress, containerArtifact.abi, provider);
    const tokenUri = await containerContract.tokenURI(1);

    console.log(tokenUri);
    display.innerHTML = tokenUri;
  }
</script>


<main>
  {#if (isConnected)}
    <button on:click={handleDisconnectWallet}>Disconnect</button>
    <button on:click={handleLoadContainer}>Load Container</button>
    <div bind:this={display}></div>
  {:else}
    <button on:click={handleConnectWallet}>Connect</button>
  {/if}
</main>
