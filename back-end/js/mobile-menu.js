const mobileMenu = document.getElementById('mobile-menu');
const navLinks = document.querySelector('.nav-links');
const container = document.querySelector('.container');
const bar1 = document.querySelector('.bar1');
const bar2 = document.querySelector('.bar2');
const bar3 = document.querySelector('.bar3');

mobileMenu.addEventListener('click', () => {
    navLinks.classList.toggle('active');
    container.classList.toggle('invisible');
    bar1.classList.toggle('open');
    bar2.classList.toggle('open');
    bar3.classList.toggle('open');
});
