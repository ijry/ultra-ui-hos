import { UPBuilder } from './UPTypes';

/** Type guard kept in the public entry point for slot adapters. */
export function isBuilder(value: UPBuilder | undefined | null): boolean {
  return typeof value === 'function';
}
