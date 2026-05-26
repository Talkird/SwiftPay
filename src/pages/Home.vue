<script setup lang="ts">
import { ref, onMounted } from "vue";
import { marked } from "marked";

interface CostChange {
  _id?: string;
  body: string;
  prNumber?: string;
  author?: string;
  branch?: string;
  date: string;
}

const changes = ref<CostChange[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);

const fetchChanges = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await fetch(
      "https://6i0kggdgzh.execute-api.us-east-1.amazonaws.com/responses",
    );
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    console.log("API response status:", response.status);
    const data = await response.json();
    changes.value = Array.isArray(data) ? data : data.responses || [];
    console.log(data);
  } catch (err) {
    error.value = err instanceof Error ? err.message : "Failed to fetch data";
    console.error("Error fetching changes:", err);
  } finally {
    loading.value = false;
  }
};

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const renderMarkdown = (content: string) => {
  return marked(content);
};

onMounted(() => {
  fetchChanges();
});
</script>

<template>
  <div class="min-h-screen bg-white">
    <!-- Header -->
    <header class="border-b border-gray-200 bg-white sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-6 py-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-4xl font-bold text-gray-900">
              Infrastructure Costs
            </h1>
            <p class="text-gray-600 mt-2">
              Track changes in your cloud infrastructure costs
            </p>
          </div>
          <UButton
            loading-auto
            size="xl"
            class="px-6 py-3 text-white font-bold"
            @click="fetchChanges"
          >
            Refresh
          </UButton>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-6 py-12">
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="flex flex-col items-center gap-4">
          <div
            class="w-12 h-12 border-4 border-gray-200 border-t-blue-500 rounded-full animate-spin"
          ></div>
          <p class="text-gray-600 text-lg">Loading cost changes...</p>
        </div>
      </div>

      <!-- Error State -->
      <div
        v-else-if="error"
        class="rounded-lg bg-red-50 border border-red-200 p-6"
      >
        <div class="flex gap-4">
          <div class="flex-shrink-0">
            <svg
              class="h-6 w-6 text-red-500"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4v2m0 4v2M7 9h10M7 13h10M7 17h10M3 3h18a2 2 0 012 2v14a2 2 0 01-2 2H3a2 2 0 01-2-2V5a2 2 0 012-2z"
              />
            </svg>
          </div>
          <div>
            <h3 class="text-lg font-medium text-red-800">Error loading data</h3>
            <p class="text-red-700 mt-1">{{ error }}</p>
            <button
              @click="fetchChanges"
              class="mt-4 inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <svg
                class="w-4 h-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                />
              </svg>
              Retry
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="changes.length === 0" class="text-center py-20">
        <svg
          class="mx-auto h-16 w-16 text-gray-300"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M20 21l-4.35-4.35M11 19a8 8 0 100-16 8 8 0 000 16z"
          />
        </svg>
        <h3 class="mt-4 text-lg font-medium text-gray-900">
          No cost changes found
        </h3>
        <p class="text-gray-600 mt-2">
          There are no infrastructure cost changes to display yet.
        </p>
      </div>

      <!-- Cost Changes List -->
      <div v-else class="space-y-4">
        <div
          v-for="(change, index) in changes"
          :key="change._id || index"
          class="rounded-lg border border-gray-200 bg-white p-6 hover:shadow-lg transition-shadow"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="flex-1">
              <div class="mb-4">
                <div class="flex items-center gap-3 mb-4">
                  <div class="flex-shrink-0">
                    <div
                      class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100"
                    >
                      <UIcon
                        name="i-lucide-circle-dollar-sign"
                        class="size-8 text-primary"
                      />
                    </div>
                  </div>
                  <time class="text-sm font-medium text-gray-500">
                    {{ formatDate(change.date) }}
                  </time>
                </div>
                <div class="flex flex-wrap gap-2">
                  <UBadge v-if="change.author" color="primary" variant="subtle">
                    <UIcon name="i-lucide-user" class="size-5 text-primary" />
                    {{ change.author }}
                  </UBadge>
                  <UBadge
                    v-if="change.branch"
                    color="primary"
                    variant="outline"
                  >
                    <UIcon name="i-lucide-git-branch-plus" class="size-5" />
                    {{ change.branch }}
                  </UBadge>
                  <UBadge
                    v-if="change.prNumber"
                    color="primary"
                    variant="outline"
                  >
                    PR #{{ change.prNumber }}
                  </UBadge>
                </div>
              </div>
              <div
                class="prose prose-sm max-w-none text-gray-700"
                v-html="renderMarkdown(change.body)"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
