// Tests written with Jest 29.x – expect(), describe(), it() style

const fs = require('fs');
const { validateConfig } = require('../../src/utils/configValidation');

jest.spyOn(fs, 'readFileSync').mockReturnValue('{}');

afterEach(() => {
  jest.resetAllMocks();
  delete process.env.PORT;
});

describe('validateConfig', () => {
  describe('Happy paths', () => {
    const cases = [
      { host: 'localhost', port: 80 },
      { host: '127.0.0.1', port: 0 },
      { host: 'example.com', port: 65535, ssl: true },
    ];
    test.each(cases)('returns true for %# – %o', (cfg) => {
      expect(validateConfig(cfg)).toBe(true);
    });
  });

  describe('Edge cases – missing or null input', () => {
    const badInputs = [
      undefined,
      null,
      {},
      { port: 3000 },          // missing host
      { host: 'foo' },         // missing port
    ];
    test.each(badInputs)('throws for %# – %o', (cfg) => {
      expect(() => validateConfig(cfg)).toThrow();
    });
  });

  describe('Failure conditions – invalid values', () => {
    const invalids = [
      { host: 123, port: 80 },                 // host not a string
      { host: 'localhost', port: 'eighty' },   // port not a number
      { host: 'localhost', port: -1 },         // port too low
      { host: 'localhost', port: 70000 },      // port too high
      { host: 'localhost', port: 80, foo: 'bar' }, // unexpected key
    ];
    test.each(invalids)('rejects %# – %o', (cfg) => {
      expect(() => validateConfig(cfg)).toThrow();
    });
  });

  it('honours PORT env var fallback', () => {
    process.env.PORT = '1234';
    const cfg = { host: 'localhost' };  // omit port to use env fallback
    expect(validateConfig(cfg)).toBe(true);
  });
});