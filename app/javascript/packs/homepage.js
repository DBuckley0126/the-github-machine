document.addEventListener("DOMContentLoaded", function(){
  const usernameInput = document.querySelector('#username');
  const formContainerBorder = document.querySelector('#form-container-border');
  const message = document.querySelector('#message')
  const submitButton = document.querySelector('#submit-button')

  let usernameInputContainsValue = false

  const handleInput = () => {
    if(!usernameInput.value == ""){
      usernameInputContainsValue = true
      formContainerBorder.className = "inputContainsValue"
    } else {
      usernameInputContainsValue = false
      formContainerBorder.className = "inputNoValue"
    }
  }

  submitButton.addEventListener('click', () => {
    if(usernameInputContainsValue){
      formContainerBorder.className = "loading"
    }
  })

  usernameInput.oninput = handleInput;

  setTimeout(()=> {
    message.className = "indexMessageShow"
  }, 500)

  setTimeout(()=> {
    message.className = "indexMessageRemove"
  }, 3000)


})
