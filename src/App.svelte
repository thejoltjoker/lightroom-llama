<script>
	import './app.css';
	import Footer from './lib/Footer.svelte';
	import Hero from './lib/Hero.svelte';
	import Navbar from './lib/Navbar.svelte';
	import PrerequisitesSection from './lib/sections/Prerequisites/PrerequisitesSection.svelte';
	import InstallSection from './lib/sections/Install/InstallSection.svelte';
</script>

<Navbar />
<Hero />
<main>
	<PrerequisitesSection />
	<InstallSection />
</main>
<Footer />
