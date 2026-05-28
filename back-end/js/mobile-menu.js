const mobileMenu = document.getElementById('mobile-menu');

const navLinks = document.querySelector('.nav-links');

const container = document.querySelector('.container');

const bars = document.querySelectorAll(
    '.bar1, .bar2, .bar3'
);

mobileMenu.addEventListener('click', () => {

    navLinks.classList.toggle('active');

    container.classList.toggle('invisible');

    bars.forEach(bar => {
        bar.classList.toggle('open');
    });

});

/* Fecha o menu ao clicar em um link */

document.querySelectorAll('.nav-links a')
.forEach(link => {

    link.addEventListener('click', () => {

        navLinks.classList.remove('active');

        container.classList.remove('invisible');

        bars.forEach(bar => {
            bar.classList.remove('open');
        });

    });

});

/* Fecha o menu clicando fora */

document.addEventListener('click', (event) => {

    const clicouNoMenu =
        navLinks.contains(event.target);

    const clicouNoBotao =
        mobileMenu.contains(event.target);

    if (
        !clicouNoMenu &&
        !clicouNoBotao &&
        navLinks.classList.contains('active')
    ) {

        navLinks.classList.remove('active');

        container.classList.remove('invisible');

        bars.forEach(bar => {
            bar.classList.remove('open');
        });

    }

});

/* Fecha o menu ao redimensionar tela */

window.addEventListener('resize', () => {

    if (window.innerWidth > 768) {

        navLinks.classList.remove('active');

        container.classList.remove('invisible');

        bars.forEach(bar => {
            bar.classList.remove('open');
        });

    }

});