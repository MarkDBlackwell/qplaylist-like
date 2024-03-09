/*
Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

'use strict';

(function() {
	const regexp = /LatestFiveLike(.*)\.html$/;
	const channel = window.location.pathname.match(regexp)[1];
	const node = document.querySelector('main');

	const functionConsoleWarningPreventAndLoad = function(channel, node) {
//In Firefox, the warning was, "Layout was forced before the page."
		window.addEventListener('load', function() {
			Elm.Main.init(
				{
					flags: channel,
					node: node,
				}
			);
		});
	};

	functionConsoleWarningPreventAndLoad(channel, node);
})();
