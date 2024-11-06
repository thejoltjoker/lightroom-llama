<script>
	import OsWindow from './OsWindow.svelte';
	import llamaPicture from '../assets/llama.jpg';
</script>

<div class="container flex flex-col items-center justify-center h-[80vh] gap-3">
	<div class="w-full mb-24">
		<OsWindow title="Lightroom Llama">
			<div class="grid grid-cols-2 gap-6 p-6">
				<div class="">
					<img src={llamaPicture} alt="Llama" class=" border-lightroom-950 border-2" />
				</div>
				<div class="flex flex-col gap-4">
					<fieldset class="flex flex-col">
						<label for="title">Title:</label>
						<input
							type="text"
							id="title"
							value="A Confused Llama"
							class="rounded-md border-lightroom-400"
						/>
					</fieldset>
					<fieldset class="flex flex-col">
						<label for="prompt">Caption:</label>
						<textarea id="caption" class="rounded-md border-lightroom-400 resize-none" rows="4"
							>The sun is setting behind them, casting a warm glow over the scene.</textarea
						>
					</fieldset>
				</div>
			</div>
		</OsWindow>
	</div>
	<h1 class="text-4xl font-bold">Talk to your llama from within Lightroom</h1>
	<p class="text-lg">Integrate LLM in Lightroom</p>
	<button class="button">Get Started</button>
</div>
