function mostrarSecao(secaoId) {
    const secoes = document.querySelectorAll('.secao');
    secoes.forEach((secao) => secao.classList.remove('ativa'));

    document.getElementById(secaoId).classList.add('ativa');
}

async function sair() {
    const req = await fetch("../../back-end/php/logout.php");
    const resp = await req.text();

    if (resp === "OK") {
        window.location.href = "../../front-end/html/login.html";
    } else {
        alert("Erro ao sair.");
    }
}
