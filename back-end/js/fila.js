function mostrarNotificacao() {
  const nota = document.getElementById("notificacao");
  if (nota) {
    nota.style.display = "block";
    setTimeout(() => {
      nota.style.display = "none";
    }, 3000);
  }
}

const formatarMoeda = (valor) => new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);

const formatarData = (dataStr) => {
    const data = new Date(dataStr.replace(' ', 'T'));
    return data.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
};

function updateStatus(id, novoStatus, selectElement) {
    selectElement.disabled = true;

    const formData = new FormData();
    formData.append("id", id);
    formData.append("status", novoStatus);

    fetch("../../back-end/php/atualizar_status.php", {
        method: "POST",
        body: formData,
    })
    .then((response) => response.json())
    .then((data) => {
        if (data.success) {
            mostrarNotificacao();
            carregarPedidos();
        } else {
            alert("Erro ao atualizar status.");
            selectElement.disabled = false;
        }
    });
}

function carregarPedidos() {
    fetch("../../back-end/php/buscar_pedidos.php")
        .then((res) => res.json())
        .then((data) => {
            const tbody = document.getElementById("lista-pedidos");
            tbody.innerHTML = "";

            document.getElementById("total-dia").textContent = data.length;

            document.getElementById("concluidos").textContent =
                data.filter(p => p.status === "Concluido").length;

            document.getElementById("entrega").textContent =
                data.filter(p => p.status === "Saiu para entrega").length;

            document.getElementById("preparo").textContent =
                data.filter(p => p.status === "Em preparo").length;

            document.getElementById("cancelados").textContent =
                data.filter(p => p.status === "Cancelado").length;

            data.forEach((pedido) => {
                const tr = document.createElement("tr");
                const badgeClass = pedido.status === 'Concluido'
                        ? 'badge-concluido'
                        : pedido.status === 'Saiu para entrega'
                        ? 'badge-entrega'
                        : pedido.status === 'Cancelado'
                        ? 'badge-cancelado'
                        : 'badge-preparo';

                tr.innerHTML = `
                    <td>#${pedido.id}</td>
                    <td>${pedido.nome}</td>
                    <td><span class="badge ${badgeClass}">${pedido.status}</span></td>
                    <td>${formatarMoeda(pedido.total)}</td>
                    <td>${formatarData(pedido.data_pedido)}</td>
                    <td><select onchange="updateStatus(${pedido.id}, this.value, this)">
                        <option value="Em preparo" ${pedido.status === "Em preparo" ? "selected" : ""}>Em preparo</option>
                        <option value="Saiu para entrega" ${pedido.status === "Saiu para entrega" ? "selected" : ""}>Saiu para entrega</option>
                        <option value="Concluido" ${pedido.status === "Concluido" ? "selected" : ""}>Concluido</option>
                        <option value="Cancelado" ${pedido.status === "Cancelado" ? "selected" : ""}>Cancelado</option>
                        </select></td>
                `;
                tbody.appendChild(tr);
            });
        });
}

function exportarCSV() {

    window.location.href =
        "../../back-end/php/exportar_pedidos.php";

}

document.addEventListener("DOMContentLoaded", carregarPedidos);
