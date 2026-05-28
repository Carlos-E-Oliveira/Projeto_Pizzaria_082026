async function cancelarPedido(idPedido) {

    const confirmar = confirm(
        "Deseja realmente cancelar este pedido?"
    );

    if (!confirmar) return;

    try {

        const dados = new FormData();

        dados.append("id", idPedido);

        const req = await fetch(
            "../../back-end/php/cancelar_pedido.php",
            {
                method: "POST",
                body: dados
            }
        );

        const resp = await req.text();

        if (resp.trim() === "OK") {

            alert("Pedido cancelado.");

            location.reload();

        } else {

            alert(resp);

        }

    } catch (erro) {

        console.error(erro);

        alert("Erro ao cancelar pedido.");

    }
}