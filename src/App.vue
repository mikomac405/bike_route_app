<script setup>
import { ref, watch } from 'vue';

const destination = ref('');
const showCurrentLocationInput = ref(false);

watch(destination, (newValue) => {
  showCurrentLocationInput.value = newValue.trim().length > 0;
});
</script>

<template>
  <main>
    <div class="wrapper">
      <h3 class="label">Podaj cel podróży</h3>

      <input
          type="text"
          id="destination"
          v-model="destination"
          placeholder="Input your destination"
      /><br />

      <transition name="fade">
        <div v-if="showCurrentLocationInput">
          <h3 class="label">Podaj swoją lokalizację</h3>
          <input type="text" id="currentLocation" placeholder="Input your current location" /><br />
        </div>
      </transition>

      <!-- Submit Button -->
      <button id="submitButton">Submit</button>
    </div>
  </main>
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

/* Slowed down animation */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.7s ease; /* Slowed down duration */
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
