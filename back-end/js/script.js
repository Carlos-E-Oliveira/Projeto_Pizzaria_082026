let carrinho = [];

function adicionarAoCarrinho(nome, preco) {
    carrinho.push({ nome, preco });
    alert(`${nome} adicionada ao carrinho!`);
}

function adicionarAoCarrinho(nomePizza, preco) {
    alert(`Você adicionou ${nomePizza} ao carrinho por R$ ${preco.toFixed(2)}`);
}

function mostrarCarrinho() {
    const carrinhoItems = document.getElementById('carrinho-items');
    const totalElement = document.getElementById('total');
    carrinhoItems.innerHTML = '';
    let total = 0;

    carrinho.forEach((item) => {
        carrinhoItems.innerHTML += `<p>${item.nome} - R$ ${item.preco}</p>`;
        total += item.preco;
    });

    totalElement.textContent = total.toFixed(2);
}

function finalizarCompra() {
    const pagamento = document.getElementById('pagamento').value;
    let mensagem = 'Pedido:\n';

    carrinho.forEach((item) => {
        mensagem += `${item.nome} - R$ ${item.preco}\n`;
    });

    mensagem += `Total: R$ ${carrinho
        .reduce((acc, item) => acc + item.preco, 0)
        .toFixed(2)}\n`;
    mensagem += `Forma de Pagamento: ${pagamento}\n`;

    const whatsappUrl = `https://wa.me/5511999999999?text=${encodeURIComponent(
        mensagem
    )}`;
    window.location.href = whatsappUrl;
}

// Chamar mostrarCarrinho na página do carrinho
if (document.getElementById('carrinho-items')) {
    mostrarCarrinho();
}
