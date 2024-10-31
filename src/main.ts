import { mount } from 'svelte';
import './app.css';
import App from './App.svelte';

import '@fontsource-variable/figtree';
import '@fontsource-variable/jetbrains-mono';
import '@fontsource/noto-color-emoji';

const app = mount(App, {
	target: document.getElementById('app')!
});

export default app;
