<script>
	import Tabs from './Tabs.svelte';
</script>

<section class="bg-lightroom-900 text-white h-[80vh] flex items-center">
	<div class="container text-center flex flex-col gap-4 justify-center items-center h-[50%]">
		<h2 class="text-4xl font-bold">Breed your llama</h2>
		<p class="max-w-md">Follow these simple steps to get started with ollama.</p>
		<Tabs />
	</div>
</section>

<style lang="postcss">
	.active {
		@apply bg-white text-lightroom-950;
	}
</style>
