<script>
	import './app.css';
	import svelteLogo from './assets/svelte.svg';
	import viteLogo from '/vite.svg';
	import Counter from './lib/Counter.svelte';
	import Navbar from './lib/Navbar.svelte';
	import Hero from './lib/Hero.svelte';
	import InstallOllamaSection from './lib/sections/InstallOllamaSection.svelte';
</script>

<Navbar />
<Hero />
<main>
	<InstallOllamaSection />
</main>
