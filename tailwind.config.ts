import type { Config } from 'tailwindcss';

export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		extend: {
			fontFamily: {
				sans: ['Figtree Variable', 'Noto Color Emoji', 'sans-serif'],
				mono: ['JetBrains Mono Variable', 'Noto Color Emoji', 'monospace'],
				emoji: ['Noto Color Emoji', 'Noto Color Emoji', 'sans-serif']
			},
			colors: {
				lightroom: {
					'50': '#f5f5f6',
					'100': '#e6e6e7',
					'200': '#DADADA',
					'300': '#B9BAB9',
					'400': '#878789',
					'500': '#6c6c6e',
					'600': '#5d5c5e',
					'700': '#505051',
					'800': '#454545',
					'900': '#3c3c3d',
					'950': '#212121',
					green: '#58be5c'
				},
				'lr-blue': {
					'50': '#eff7ff',
					'100': '#dfeeff',
					'200': '#b8dfff',
					'300': '#78c5ff',
					'400': '#31a8ff',
					'500': '#068df1',
					'600': '#006ece',
					'700': '#0058a7',
					'800': '#024a8a',
					'900': '#083f72',
					'950': '#06274b'
				}
			}
		}
	},
	safelist: ['trigger'],
	plugins: [require('@tailwindcss/forms')]
} as Config;
