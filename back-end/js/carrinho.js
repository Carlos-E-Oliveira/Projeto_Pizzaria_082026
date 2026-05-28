let carrinho = [];

function carregarCarrinho() {
    const carrinhoSalvo = localStorage.getItem('carrinho');
    if (carrinhoSalvo) {
        carrinho = JSON.parse(carrinhoSalvo);
        atualizarCarrinho();
    }
}

function atualizarCarrinho() {
    const carrinhoDiv = document.getElementById('carrinho');
    carrinhoDiv.innerHTML = '';
    let total = 0;

    carrinho.forEach((item, index) => {
        carrinhoDiv.innerHTML += `
                    <div class="carrinho-item">
                        <span>${item.pizza}</span>
                        <span>R$ ${item.preco}</span>
                        <button class="remover-btn" onclick="removerDoCarrinho(${index})">Remover</button>
                    </div>`;
        total += item.preco;
    });

    document.getElementById('total').innerText =
        'Total: R$ ' + total.toFixed(2);
}

function removerDoCarrinho(index) {
    carrinho.splice(index, 1);
    salvarCarrinho();
    atualizarCarrinho();
}

function salvarCarrinho() {
    localStorage.setItem('carrinho', JSON.stringify(carrinho));
}

carregarCarrinho();

const modal = document.getElementById('enderecoModal');

function abrirModal() {
    modal.style.display = 'block';
}

function fecharModal() {
    modal.style.display = 'none';
}

window.onclick = function (event) {
    if (event.target == modal) {
        fecharModal();
    }
};

document.getElementById('enderecoForm').onsubmit = function (e) {
    e.preventDefault();
    const nome = document.getElementById('nome').value;
    const endereco = document.getElementById('endereco').value;
    const cidade = document.getElementById('cidade').value;
    const cep = document.getElementById('cep').value;

    alert(
        `Pedido confirmado!\nNome: ${nome}\nEndereço: ${endereco}, ${cidade}\nCEP: ${cep}`
    );
    fecharModal();
    localStorage.removeItem('carrinho');
    carrinho = [];
    atualizarCarrinho();
};

async function finalizarPedido() {

    let pedido = '';
    let total = 0;

    carrinho.forEach((item) => {
        pedido += `${item.pizza} - R$ ${item.preco.toFixed(2)}\n`;
        total += item.preco;
    });

    const formaPagamento = document.querySelector(
        'input[name="pagamento"]:checked'
    )?.value;

    const nome = document.getElementById('nome').value;
    const endereco = document.getElementById('endereco').value;
    const cidade = document.getElementById('cidade').value;
    const cep = document.getElementById('cep').value;

    if (!nome || !endereco || !cidade || !cep || !formaPagamento) {
        alert("Preencha todos os campos.");
        return;
    }

    try {

        const dados = new FormData();

        dados.append("nome", nome);
        dados.append("endereco", endereco);
        dados.append("cidade", cidade);
        dados.append("cep", cep);
        dados.append("formaPagamento", formaPagamento);
        dados.append("pedido", pedido);
        dados.append("total", total.toFixed(2));

        const req = await fetch("../../back-end/php/pedido.php", {
            method: "POST",
            body: dados
        });

        const resp = await req.text();

        if (resp.trim() !== "OK") {
            alert(resp);
            return;
        }

        const mensagem = `
            *Pedido Confirmado!*

            *Itens do pedido:*
            ${pedido}

            Nome: ${nome}
            Endereço: ${endereco}, ${cidade}
            CEP: ${cep}

            *Total:* R$ ${total.toFixed(2)}
            *Forma de Pagamento:* ${formaPagamento}

            Obs: Valores referente ao frete serão informados via WhatsApp.
        `;

        const mensagemCodificada = encodeURIComponent(mensagem);

        const numeroWhatsApp = '5575991479048';

        const urlWhatsApp =
            `https://wa.me/${numeroWhatsApp}?text=${mensagemCodificada}`;

        localStorage.removeItem('carrinho');
        carrinho = [];
        atualizarCarrinho();

        window.open(urlWhatsApp, '_blank');

    } catch (erro) {

        console.error(erro);
        alert("Erro ao finalizar pedido.");

    }
}