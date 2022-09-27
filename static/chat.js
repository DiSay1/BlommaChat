const socket = new WebSocket('ws://'+window.location.host+'/chat.lua');

let chatBox = document.getElementById("chatBox");
let params = (new URL(document.location)).searchParams; 

// Connection opened
socket.addEventListener('open', (event) => {
    let jsonToSend = {
        "msgType": "connect",
        "key": params.get("key"),
        "id": parseInt(params.get("id"), 10),
    }

    socket.send(JSON.stringify(jsonToSend));

    console.log("Successful connection to the server");
});

let connected = false;

if (!window["WebSocket"]) {
    let msgElement = document.createElement("div");

    let viewMessage = `
        <div id="message" style="text-align: left; margin-left: 2rem;">
            <p id="msgAuthor" style="color: rgb(0, 130, 130);">`+"Client"+`<b>- ></b></p> 
            <div id="msgText" style="text-overflow: clip; width: 80%;">
                `+"<b>Your browser does not support WebSockets.</b>"+`
            </div>
        </div>
        <hr/>
        `;

    msgElement.innerHTML = viewMessage;
    chatBox.appendChild(msgElement);
}

// Listen for messages
socket.addEventListener('message', (event) => {
    let msg = JSON.parse(event.data);

    switch (msg["msgType"]) {
        case "connect":
            if (msg["code"] == 101) {
                connected = true;

                let msgElement = document.createElement("div");

                let viewMessage = `
                    <div id="message" style="text-align: left; margin-left: 2rem;">
                        <p id="msgAuthor" style="color: rgb(0, 130, 130);">`+"Server"+`<b>- ></b></p> 
                        <div id="msgText" style="text-overflow: clip; width: 80%;">
                            `+"Have a nice chat!"+`
                        </div>
                    </div>
                    <hr/>
                `;

                msgElement.innerHTML = viewMessage;
                chatBox.appendChild(msgElement);
            } else if (msg["code"] == 0) {
                let msgElement = document.createElement("div");

                let viewMessage = `
                    <div id="message" style="text-align: left; margin-left: 2rem;">
                        <p id="msgAuthor" style="color: rgb(0, 130, 130);">`+"Server"+`<b>- ></b></p> 
                        <div id="msgText" style="text-overflow: clip; width: 80%;">
                            `+"Connection error!"+`
                        </div>
                    </div>
                    <hr/>
                `;
                msgElement.innerHTML = viewMessage;
                chatBox.appendChild(msgElement);

            }
            break;
    
        case "message":
            if (msg["code"] == 202) {
                let msgElement = document.createElement("div");

                let viewMessage = `
                    <div id="message" style="text-align: left; margin-left: 2rem;">
                        <p id="msgAuthor" style="color: rgb(0, 130, 130);">`+msg["userName"]+`<b>- ></b></p> 
                        <div id="msgText" style="text-overflow: clip; width: 80%;">
                            `+msg["msgText"]+`
                        </div>
                    </div>
                    <hr/>
                `;

                msgElement.innerHTML = viewMessage;
                chatBox.appendChild(msgElement);
            }
            break;
    }
});

function sendMessage() {
    let message = document.getElementById("msgInput").value;

    let jsonMessage = {
        "msgType": "message",
        "key": params.get("key"),
        "id": parseInt(params.get("id"), 10),
        "msgText": message,
    }

    let str = JSON.stringify(jsonMessage)

    console.log(str)

    socket.send(str);

    document.getElementById("msgInput").value = "";
}