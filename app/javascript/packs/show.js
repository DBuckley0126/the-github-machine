document.addEventListener('DOMContentLoaded', function() {
  const pieStyleVariables = document.querySelectorAll('.hidden-pie-variable')
  const pieSegmants = document.querySelectorAll('.pie__segment')
  const labelContainers = document.querySelectorAll('.label-container')

  pieSegmants.forEach((segmant, index) => {
    segmant.setAttribute('style', pieStyleVariables[index].innerText)
    segmant.addEventListener('mouseover', () => {
      labelContainers[index].className =
        'label-container label-container-heighlighted'
    })
    segmant.addEventListener('mouseout', () => {
      labelContainers[index].className = 'label-container'
    })
  })
})
