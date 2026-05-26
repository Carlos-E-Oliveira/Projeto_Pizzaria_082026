let carrinho = [];

function carregarCarrinho() {
    const carrinhoSalvo = localStorage.getItem('carrinho');
    if (carrinhoSalvo) {
        carrinho = JSON.parse(carrinhoSalvo);
    }
}

function adicionarAoCarrinho(pizza, preco) {
    carrinho.push({ pizza: pizza, preco: preco });
    alert(pizza + ' foi adicionada ao carrinho por R$ ' + preco);
    salvarCarrinho();
}

function salvarCarrinho() {
    localStorage.setItem('carrinho', JSON.stringify(carrinho));
}

carregarCarrinho();

function carregarPizzas() {
    const pizzaList = document.getElementById('pizza-list');
    pizzaList.innerHTML = ''; // Limpar lista atual

    // Fazer requisição ao servidor
    fetch('../../back-end/php/listar_pizzas.php')
        .then((response) => response.json())
        .then((pizzas) => {
            pizzas.forEach((pizza) => {
                pizzaList.innerHTML += `
                            <div class="pizza-item">
                                <h4>${pizza.nome}</h4>
                                <img src="../../front-end/${pizza.imagem}" alt="${pizza.nome}">
                                <p>${pizza.descricao}</p>
                                <div class="buttons">
                                    <button class="cssbuttons-io-button" onclick="adicionarAoCarrinho('${pizza.nome} P', ${pizza.precoP})">
                                        <svg height="24" width="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M0 0h24v24H0z" fill="none"></path>
                                            <path d="M11 11V5h2v6h6v2h-6v6h-2v-6H5v-2z" fill="currentColor"></path>
                                        </svg>
                                        <span>P - R$ ${pizza.precoP}</span>
                                    </button>
                                    <button class="cssbuttons-io-button" onclick="adicionarAoCarrinho('${pizza.nome} M', ${pizza.precoM})">
                                        <svg height="24" width="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M0 0h24v24H0z" fill="none"></path>
                                            <path d="M11 11V5h2v6h6v2h-6v6h-2v-6H5v-2z" fill="currentColor"></path>
                                        </svg>
                                        <span>M - R$ ${pizza.precoM}</span>
                                    </button>
                                    <button class="cssbuttons-io-button" onclick="adicionarAoCarrinho('${pizza.nome} G', ${pizza.precoG})">
                                        <svg height="24" width="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M0 0h24v24H0z" fill="none"></path>
                                            <path d="M11 11V5h2v6h6v2h-6v6h-2v-6H5v-2z" fill="currentColor"></path>
                                        </svg>
                                        <span>G - R$ ${pizza.precoG}</span>
                                    </button>
                                </div>
                            </div>
                        `;
            });
        })
        .catch((err) => console.error('Erro ao carregar pizzas:', err));
}

window.onload = function () {
    carregarPizzas();
};
