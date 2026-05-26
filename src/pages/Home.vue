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
  <div class="min-h-screen bg-gray-100">
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

    <main>
      <div class="space-y-4">
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
                      class="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100"
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
