<script setup>

</script>

<template>
  <div class="wrapper">
    <h3 class="label">Input your route</h3>

    <input type="text" id="currentLocation" placeholder="Input your current location"/><br/>

    <input
        type="text"
        id="destination"
        placeholder="Input your destination"
    /><br/>


    <!-- Submit Button -->
    <button id="submitButton">Submit</button>

  </div>
</template>

<style scoped>
.wrapper {
  text-align: left; /* Align the whole content to the left */
  display: inline-block; /* Ensure that wrapper div adapts to the content width */
}

.label {
  text-align: left;
  margin-bottom: 5px;
}

input {
  margin: 10px 0;
  padding: 8px;
  width: 200px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

button {
  margin-top: 15px;
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #45a049;
}
</style>
